Received: from srv11-sao.sao.terra.com.br (srv11-sao.sao.terra.com.br [200.246.248.66])
	by srv12-sao.sao.terra.com.br (8.9.3/8.9.3) with ESMTP id SAA13462
	for <linux-mm@kvack.org>; Tue, 31 Oct 2000 18:20:48 -0200
Received: from einstein (root@dl-tnt7-C8B08DF9.sao.terra.com.br [200.176.141.249])
	by srv11-sao.sao.terra.com.br (8.9.3/8.9.3) with ESMTP id SAA17207
	for <linux-mm@kvack.org>; Tue, 31 Oct 2000 18:20:42 -0200
Date: Tue, 31 Oct 2000 17:15:51 -0200
From: "Rodrigo S. de Castro" <rodsc@bigfoot.com>
Subject: Re: [RFC] Structure in Compressed Cache
Message-ID: <20001031171551.A978@einstein>
References: <20001030190922.A5183@linux.ime.usp.br> <Pine.LNX.4.21.0010311404210.1475-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.21.0010311404210.1475-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, Oct 31, 2000 at 02:06:08PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, kernel@tutu.ime.usp.br
List-ID: <linux-mm.kvack.org>

On Tue, Oct 31, 2000 at 02:06:08PM -0200, Marcelo Tosatti wrote:
> On Mon, 30 Oct 2000, Rodrigo S. de Castro wrote:
> > 	In my implementation of compressed cache (kernel 2.2.16), I
> > started the project having my cache as a slab cache, structure
> > provided by kernel. I have all step 1 (a cache with no compression)
> > done, but I had a problem with marking pages in my cache. After an
> > email sent to the list about this subject, I started looking at shared
> > memory mechanism (mainly ipc/shm.c), and I saw that there's another
> > way of making it: with a page table allocation and memory mapping. I
> > could go on with my initial idea (with slab cache) but I think that
> > doing the latter way (with page table and memory mapping) would be
> > more complete (and, of course, harder). I will have a pool of
> > (compressed) pages that gotta be always in memory and will be
> > "between" physical memory and swap. As the project is growing I would
> > like to define now which path to follow, taking in account
> > completeness and upgradeability (to future versions of kernel). Which
> > way do you think that is better? Please, I also ask you to tell me in
> > case you know if there's another way, maybe better, of doing it.
> 
> Slab cache memory is physically contiguous and non swappable, so it may be
> a waste to use it to cache userspace data. 

	Data in slab cache is not supposed to be swapped. Currently,
the slab cache stores only a structure with some information (such as
task, original pte) and a pointer to a physical page that is allocated
at the beginning of my compressed_init() function. I manage, when
cache fills up, to swap data present in slab cache. It will be user
data (every data that may be swapped), but it will managed by our
functions. It seemed to me that a page table (with memory mapping)
would be a better choice to put all compressed levels in the same
"level" as shared pages, for example, and it seemed to be more
complete. What do you think? I hope I haven't said something too
wrong. :-)
	Would I have problem with slab cache when it grows and
shrinks, in one advanced phase of our project, due to have contiguous
data? I couldn't notice this problem when I read some papers about
slab cache, but I am not sure as well.
	Slab cache was our first choice because it allowed this
dynamism (growing and shrinking) with no big effort. In the case of
having a page table, we must have all engine built to support this
feature.

Thank you very much for your help,
-- 
Rodrigo S. de Castro   <rcastro@linux.ime.usp.br>
University of Sao Paulo - Brazil
Compressed Caching - http://tutu.ime.usp.br


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
