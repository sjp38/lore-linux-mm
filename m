Subject: ext3 writeback mode slower than ordered mode?
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 08 Dec 2001 22:10:00 +0100
Message-ID: <871yi5wh93.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!

My apologies if this is an FAQ, and I'm still catching up with
the linux-kernel list.

Today I decided to convert my /tmp partition to be mounted in
writeback mode, as I noticed that ext3 in ordered mode syncs every 5
seconds and that is something defenitely not needed for /tmp, IMHO.

Then I did some tests in order to prove my theory. :)

But, alas, writeback is slower.

[ordered]
{atlas} [~]% writer 200 1
Wrote 200.00 MB in 2 seconds -> 70.92 MB/s (100.0 %CPU)

[writeback]
{atlas} [/tmp]% writer 200 1
Wrote 200.00 MB in 5 seconds -> 37.11 MB/s (96.8 %CPU)

"writer" is a simple application that just writes to a file and
deletes it afterwards. As I have 768MB RAM, 200MB doesn't trigger I/O
in neither case, so the numbers are the measure of the speed of the FS
internals, and as you can see writeback is running at half
speed (extra copy? why?). Strange...

Just to be on a safe side, I decided to test a real application, sort,
which uses $TMPDIR for temporary files. Once again, if I point $TMPDIR
to an ext3/writeback partition, sort takes longer to do its work. And
its repeatable.

[$TMPDIR=/tmp writeback]
{atlas} [~]% time sort bigfile -o outfile
sort bigfile -o outfile  40.14s user 19.84s system 95% cpu 1:02.60 total

[$TMPDIR=~ ordered]
{atlas} [~]% time sort bigfile -o outfile
sort bigfile -o outfile  40.74s user 14.78s system 97% cpu 57.196 total

Notice +5 seconds in sys time for a writeback case, and adequate
increase in wallclock time.

All tests were done on the 2.4.16, but 2.5.x series exhibit the same
behaviour. Eventually, I decided to continue mounting /tmp in the
default, ordered mode.

I'm confused, TIA for anybody clarifying this to me!
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
