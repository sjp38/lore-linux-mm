Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: Yet another bogus piece of do_try_to_free_pages()
Date: Wed, 10 Jan 2001 23:19:47 +0100
References: <Pine.LNX.4.21.0101100425150.7931-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0101100425150.7931-100000@freak.distro.conectiva>
MIME-Version: 1.0
Message-Id: <01011023194700.01478@dox>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 January 2001 07:39, Marcelo Tosatti wrote:
> On Tue, 9 Jan 2001, Linus Torvalds wrote:
> > I suspect that the proper fix is something more along the lines of what
> > we did to bdflush: get rid of the notion of waiting synchronously from
> > bdflush, and instead do the work yourself.
>
> Agreed.
>
> Without blocking on sync IO, kswapd can keep aging pages and moving
> them to the inactive lists.
>
> The following patch changes some stuff we've discussed before (the
> kmem_cache_reap and maxtry thingies) and it also removes the kswapd
> sleeping scheme.
>
> I haven't tested it yet, though I'll do it tomorrow.
>

I have have it running...
It gave me the highest dbench 16 result I have seen [recently begun to
run against a faster disk...]

On my PPro 180 with 96 M RAM [best of 3]
write, copy, read, diff uses plain bash commands with data of 150 or 300 MB.
[streaming]
only one run of dbench (takes tooo... much time)
[the CLIENTS goes via a symbolic link to the other disk - not perfect but...]

kernel		write	copy	read	diff	dbench
2.4.0		10.6	10.9	14.1	8.3	10.2
2.4.1-pre1+neg	10.1	10.9	14.0	8.2	10.0
2.4.1-pre1+this	11.5	10.6	14.4	8.2	10.8

as a comparisation
2.2.18		10.6	 9.7	12.8	7.2	 7.7

The only really strange thing that is common for all the 2.4 kernels is
konquerors brk usage resulting in SIGSEGV. Reported earlier to linux-kernel.

select(16, [3 4 6 7 9 10 12 13 14 15], NULL, NULL, {0, 0}) = 2 (in [7 13], 
left {0, 0})
read(13, "     4_ a_", 10)              = 10
read(13, "\0\0\0\0", 4)                 = 4
read(7, "\2\1\0\2.\1\0\0", 8)           = 8
read(7, "\1\0\0\0", 4)                  = 4
read(7, "\0\0\0\17konqueror-3415\0\0\0\0\vkonqueror"..., 302) = 302
brk(0x84f8000)                          = 0x84f8000
brk(0x84fd000)                          = 0x84fd000
brk(0x8502000)                          = 0x8502000
brk(0x8507000)                          = 0x8507000
brk(0x850c000)                          = 0x850c000
brk(0x8511000)                          = 0x8511000
brk(0x8516000)                          = 0x8516000
brk(0x851b000)                          = 0x851b000
brk(0x8520000)                          = 0x8520000
[...]
brk(0xd02d000)                          = 0xd02d000
brk(0xd02f000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
brk(0xd031000)                          = 0xd02f000
--- SIGSEGV (Segmentation fault) ---
--- SIGSEGV (Segmentation fault) ---
--- SIGSEGV (Segmentation fault) ---
+++ killed by SIGSEGV +++  


-- 
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
