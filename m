Date: Sun, 25 May 2003 13:06:01 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.69-mm9
Message-Id: <20030525130601.5a105fa8.akpm@digeo.com>
In-Reply-To: <3ED0CE0E.4080403@wmich.edu>
References: <20030525042759.6edacd62.akpm@digeo.com>
	<200305251456.39404.rudmer@legolas.dynup.net>
	<3ED0CE0E.4080403@wmich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Sweetman <ed.sweetman@wmich.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Sweetman <ed.sweetman@wmich.edu> wrote:
>
> got this with my current config. Along with other misc gcc 3 warnings.
> 
>  Compiling with gcc (GCC) 3.3 (Debian)
> 
>            ld -m elf_i386  -T arch/i386/vmlinux.lds.s
>  arch/i386/kernel/head.o arch/i386/kernel/init_task.o   init/built-in.o
>  --start-group  usr/built-in.o  arch/i386/kernel/built-in.o
>  arch/i386/mm/built-in.o  arch/i386/mach-default/built-in.o
>  kernel/built-in.o  mm/built-in.o  fs/built-in.o  ipc/built-in.o
>  security/built-in.o  crypto/built-in.o  lib/lib.a  arch/i386/lib/lib.a
>  drivers/built-in.o  sound/built-in.o  arch/i386/pci/built-in.o
>  net/built-in.o --end-group  -o vmlinux
>  kernel/built-in.o(.text+0x1708e): In function `free_module':
>  : undefined reference to `percpu_modfree'
>  kernel/built-in.o(.text+0x17873): In function `load_module':
>  : undefined reference to `find_pcpusec'
>  kernel/built-in.o(.text+0x179a9): In function `load_module':
>  : undefined reference to `percpu_modalloc'
>  kernel/built-in.o(.text+0x17c52): In function `load_module':
>  : undefined reference to `percpu_modcopy'
>  kernel/built-in.o(.text+0x17d3d): In function `load_module':
>  : undefined reference to `percpu_modfree'

Well that is strange.  The functions are there, inlined, in the right
place.

static inline unsigned int find_pcpusec(Elf_Ehdr *hdr,
					Elf_Shdr *sechdrs,
					const char *secstrings)
{
	return 0;
}
static inline void percpu_modcopy(void *pcpudst, const void *src,
				  unsigned long size)
{
	/* pcpusec should be 0, and size of that section should be 0. */
	BUG_ON(size != 0);
}
static inline void percpu_modfree(void *freeme)
{
}

It compiles OK here, uniproc and SMP.  Possibly gcc-3.3 has done something
wrong, or differently.

Does your tree build OK with earlier compilers?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
