Date: Thu, 25 Apr 2002 00:21:21 -0400
From: msimons@moria.simons-clan.com
Subject: Re: memory exhausted
Message-ID: <20020425002121.V940@moria.reston01.va.comcast.net>
References: <5.1.0.14.2.20020424145006.00b17cb0@notes.tcindex.com> <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com> <20020425025753.GJ26092@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20020425025753.GJ26092@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vivian Wang <vivianwang@tcindex.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 24 Apr 2002, Vivian Wang wrote:
> >> I try to sort my 11 GB file, but I got message about memory exhausted.
> >> sort -u file1 -o file2
> >> What I should do?

Vivian,

  If you are using the GNU version of sort it does not even try to load 
the input set into memory, it does a splintering and merge multiple merge 
sorts of the input files.  The sort operation will be very disk I/O bound...

  You must set -T (or TMPDIR) to point at a filesystem with enough disk 
space to store the temporary files if your /tmp doesn't have enough room.
You didn't paste the exact text of the error message so I didn't check 
to see what error is generated if /tmp fills up while working.


  It appears there is a restriction that sort must be able to load a few
of the longest lines into memory.

- What is the longest line in your input file?
  (run "wc -L input file")

  In my own testing of very big data files (with short line lengths)
I had no problems.  If that is a number larger than memory you may
need to find a way to chop your data into shorter lines...


  Lastly, sort splits the files into 500 KiB byte chunks on the first
pass.  This will create about 22000 files in your TMPDIR location on 
first pass, if you are using a filesystem with any sort of number of
files per directory limitation you could be having a problem there.


  Check those things and if you are still having a problem, send the
error messages you see, and some more information (like longest line).

    Good Luck,
      Mike

ps:
  I think this question may be off topic, since it's a userspace not kernel
problem... so if anyone complains you might want to take it off channel
or to some GNU textutils related mailing list.


On Wed, Apr 24, 2002 at 07:57:53PM -0700, William Lee Irwin III wrote:
> On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> On Wed, 24 Apr 2002, Vivian Wang wrote:
> >> I try to sort my 11 GB file, but I got message about memory exhausted.
> >> I used the command like this:
> >> sort -u file1 -o file2
> >> Is this correct?
> 
> On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> > Yes, sort only has a maximum of 3 GB of virtual address space so
> > it will never be able to load the whole 11 GB file into memory.
[...]
> On Wed, 24 Apr 2002, Vivian Wang wrote:
> >> What I should do?
> 
> On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> > You could either write your own sort program that doesn't need
> > to have the whole file loaded or you could use a 64 bit machine
> > with at least 11 GB of available virtual memory, probably the
> > double...
> > regards,
> > Rik
> 
> It's doubtful the above "solutions" I mentioned above are practical for
> your purposes unless you are under the most extreme duress and have
> access to uncommon hardware. I suggest polyphase merge sorting or any
> of the various algorithms recommended in Donald E. Knuth's "The Art of
> Computer Programming", specifically its chapter on external sorting,
> which I'm willing to discuss and assist in implementations of off-list.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
