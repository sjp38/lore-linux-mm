Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 22AB06B00DB
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 05:39:35 -0500 (EST)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: Is per_cpu_ptr_to_phys broken?
Date: Thu, 15 Dec 2011 11:39:31 +0100
References: <201112140033.58951.ptesarik@suse.cz> <CAM_iQpUr3MqwWzeD4Z8KzyErEM4utT=CkpbyecPu75-QDDznHQ@mail.gmail.com>
In-Reply-To: <CAM_iQpUr3MqwWzeD4Z8KzyErEM4utT=CkpbyecPu75-QDDznHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201112151139.32224.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>

Dne St 14. prosince 2011 17:17:15 Cong Wang napsal(a):
> On Wed, Dec 14, 2011 at 7:33 AM, Petr Tesarik <ptesarik@suse.cz> wrote:
> > Hi folks,
> 
> ...
> 
> > Now, the per_cpu_ptr_to_phys() function aligns all vmalloc addresses to a
> > page boundary. This was probably right when Vivek Goyal introduced that
> > function (commit 3b034b0d084221596bf35c8d893e1d4d5477b9cc), because
> > per-cpu addresses were only allocated by vmalloc if booted with
> > percpu_alloc=page, but this is no longer the case, because per-cpu
> > variables are now always allocated that way AFAICS.
> > 
> > So, shouldn't we add the offset within the page inside
> > per_cpu_ptr_to_phys?
> 
> Hi,
> 
> Tejun already fixed this, see:
> 
> commit	a855b84c3d8c73220d4d3cd392a7bee7c83de70e
> percpu: fix chunk range calculation
> author	Tejun Heo <tj@kernel.org>

Thanks for looking, but AFAICS this was a different issue. Maybe I'm missing 
something, but even with Tejun's fix, the first chunk gets allocated by 
vmalloc, and pcpu objects may not be page-aligned (as is the case with crash 
notes, which are only aligned to a word boundary).

In particular, the x86 architecture defines NEED_PER_CPU_PAGE_FIRST_CHUNK, so 
the first chunk gets allocated in pcpu_page_first_chunk():

	vm.flags = VM_ALLOC;
	vm.size = num_possible_cpus() * ai->unit_size;
	vm_area_register_early(&vm, PAGE_SIZE);

This allocates a vmalloc address which is then used to set up the first chunk:

	rc = pcpu_setup_first_chunk(ai, vm.addr);

Later on, crash notes get allocated with:

	crash_notes = alloc_percpu(note_buf_t);

which translates to
	__alloc_percpu(sizeof(note_buf_t), __alignof__(note_buf_t))

Alignment of note_buf_t is 4 bytes (it is an array of u32), so the resulting 
address may not be page-aligned. However, show_crash_notes() contains:

	addr = per_cpu_ptr_to_phys(per_cpu_ptr(crash_notes, cpunum));
	rc = sprintf(buf, "%Lx\n", addr);

Now, per_cpu_ptr() gives the correct virtual address, but 
per_cpu_ptr_to_phys() gets the result wrong, regardless whether it thinks that 
the address is in the first chunk or not:

	if (in_first_chunk) {
		if (!is_vmalloc_addr(addr))
			return __pa(addr);
		else
			return page_to_phys(vmalloc_to_page(addr));
	} else
		return page_to_phys(pcpu_addr_to_page(addr));

For anything except a non-vmalloc address, this will always round the result 
down to a page boundary. I thought this was obvious...

Petr Tesarik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
