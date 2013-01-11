Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 763C06B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 19:49:16 -0500 (EST)
Date: Fri, 11 Jan 2013 00:49:15 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
Message-ID: <20130111004915.GA15415@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

The below Ruby script reproduces the issue for me with write()
getting stuck, usually with a few iterations (sometimes up to 100).

I've reproduced this with 3.8-rc2 and rc3, even with Mel's partial
revert patch in <20130110194212.GJ13304@suse.de> applied.

I can not reproduce this with 3.7.1+
   stable-queue 2afd72f59c518da18853192ceeebead670ced5ea
So this seems to be a new bug from the 3.8 cycle...

Fortunately, this bug far easier for me to reproduce than the ppoll+send
(toosleepy) failures.

Both socat and ruby (Ruby 1.8, 1.9, 2.0 should all work), along with
common shell tools (dd, sh, cat) are required for testing this:

	# 100 iterations, raise/lower the number if needed
	ruby the_script_below.rb 100

lsof -p 15236 reveals this:
ruby    15236   ew    5u  IPv4  23066      0t0     TCP localhost:33728->localhost:38658 (CLOSE_WAIT)

$ strace -f -p 15236
Process 15236 attached - interrupt to quit
write(5, "byebye!\n", 8

So write() to fd=5 is blocked, but the lsof shows the socket is already
in CLOSE_WAIT state.  I expect write() to give me -EPIPE here since
the socat process on the reading end is long dead.

This could be an issue with sk_stream_wait_memory() that Eric Dumazet
alluded to with when I was chasing the toosleepy problem:

$ cat /proc/15236/stack 
[<ffffffff8129fb19>] release_sock+0xe5/0x11b
[<ffffffff812a6328>] sk_stream_wait_memory+0x1f7/0x1fc
[<ffffffff81040d3a>] autoremove_wake_function+0x0/0x2a
[<ffffffff812d8ebf>] tcp_sendmsg+0x710/0x86d
[<ffffffff81000e34>] __switch_to+0x235/0x3c5
[<ffffffff81299c0d>] sock_aio_write+0x102/0x10d
[<ffffffff810d0b66>] do_sync_write+0x88/0xc1
[<ffffffff810d1476>] vfs_write+0xb3/0xda
[<ffffffff81036613>] ptrace_notify+0x5d/0x76
[<ffffffff810d158e>] sys_write+0x58/0x92
[<ffffffff81322669>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

I know many of you may not be familiar with Ruby, so I've tried to
comment the code as much as possible.  Feel free to ask for
clarification.

-------------------------------- 8< -------------------------------
require 'socket'
require 'tempfile'
$stdout.sync = $stderr.sync = true # don't buffer any output

# Read the number of iterations (first command-line argument)
# (ARGV[0] in Ruby is argv[1] in C)
iterations = ARGV[0].to_i
iterations > 0 or abort "Usage: #$0 ITERATIONS (iterations should be > 0)"

# Capture a temporary file name for using in the shell script (below)
tmp = Tempfile.new('out')
out = tmp.path

# This is an array of FIFO path names, we create two of them:
fifos = []
%w(a b).each do |name|
  fifotmp = Tempfile.new([name, '.fifo'])

  # get the pathname from the Tempfile object
  fifoname = fifotmp.path
  fifos << fifoname

  # This unlinks the temporary pathname so mkfifo can succeed
  # (yes, there's a tiny race here but unlikely to ever happen).
  fifotmp.close!

  # create the FIFO
  system("mkfifo", fifoname) or abort "mkfifo #{fifoname} failed: #$?"
end

# bind to a random TCP port over loopback
addr = "127.0.0.1"
srv = TCPServer.new(addr, 0)
port = srv.addr[1]

# Start the TCP server in a child process
pid = fork do
  begin
    response = "byebye!\n"
    n = -1 # count the client number, first client is n==0
    while client = srv.accept # this is an accept(2) wrapper
      n += 1
      warn "Accepted client=#{n}"
      begin
        # this is select(2)
        warn "Waiting on client=#{n} to become readable"
        IO.select([client], nil, nil, 5) or abort "BUG: #{client} not readable"

        # read the request, it should be "hihi"
        warn "Reading from client=#{n}"
        req = client.gets
        if req =~ /hihi/
          warn "sending infinite response to client=#{n}"
          client.sync = true # do not buffer output

          # just write the response in an infinite loop on the socket
          # The client will only read 4K (see dd below), disconnect,
          # and trigger Errno::EPIPE.
          # This just calls write(2) in a loop
          loop { client.write(response) }
        else
          warn "Client sent bad request: #{req}"
        end
      rescue => e
        warn "Got #{e.class} #{e.message} error for client=#{n}"
        # this is expected, the client will only read 4K of our infinite
        # response and drop the socket.  We write to the fifo the
        # client is running: "cat #{fifos[0]} &" on
        fifo = fifos[0]
        File.open(fifo, "w") do |fp|
          warn "writing message to #{fifo} for client=#{n}"
          fp.write("CLOSING #{n}")
          warn "done writing message to #{fifo} for client=#{n}"
        end
      ensure
        warn "Done dealing with client=#{n}"
        client.close
      end
    end
  ensure
    warn "Server exiting"
  end
end

# close the server port in the main process, server is running in child
srv.close

# ensure we shut the server down at exit
at_exit do
  Process.kill(:TERM, pid)
  fifos.each { |fifopath| File.unlink(fifopath) }
  _, status = Process.waitpid2(pid)
  puts "Server exited: #{status.inspect}"
end

# inline shell script here
x = <<SH
set -e

# wait for the server to write "CLOSING" above
# After enough iterations, this can get hung up on open():
cat #{fifos[0]} > #{out} &

(
  # send a request to the server
  echo hihi

  # read 4K of the "byebye!" response
  dd bs=4096 count=1 < #{fifos[1]} > /dev/null

  # socat reads the stdout of the above ('hihi') and writes
  # it to the TCP:#{addr}:#{port}, the server response goes to fifos[1],
  # which the above dd(1) invocation reads the first 4K of.
  # This socat is expected to error out with EPIPE here
) | socat - TCP:#{addr}:#{port} > #{fifos[1]} || :

echo "Waiting on #{fifos[0]} for client=$client"
wait # for the cat fifo[0] above
grep CLOSING #{out}
> #{out}
SH

# run the above shell script, assign the client= variable to the
# iteration number
iterations.times do |i|
  system("client=#{i}\n#{x}") or abort "client #{i} failed: #$?"
end

puts "All done!"

-- 
Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
