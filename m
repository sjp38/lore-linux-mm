From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Date: Thu, 07 Jul 2016 14:35:17 +1000
Message-ID: <32293.5208947913$1467866142@news.gmane.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <1467843928-29351-10-git-send-email-keescook@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <kernel-hardening-return-3833-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1467843928-29351-10-git-send-email-keescook@chromium.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@g>, ooglemail.com, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aar>
List-Id: linux-mm.kvack.org

Kees Cook <keescook@chromium.org> writes:

> Under CONFIG_HARDENED_USERCOPY, this adds object size checking to the
> SLUB allocator to catch any copies that may span objects.
>
> Based on code from PaX and grsecurity.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>

> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff4505336..0c8ace04f075 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3614,6 +3614,33 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
>  EXPORT_SYMBOL(__kmalloc_node);
>  #endif
>  
> +#ifdef CONFIG_HARDENED_USERCOPY
> +/*
> + * Rejects objects that are incorrectly sized.
> + *
> + * Returns NULL if check passes, otherwise const char * to name of cache
> + * to indicate an error.
> + */
> +const char *__check_heap_object(const void *ptr, unsigned long n,
> +				struct page *page)
> +{
> +	struct kmem_cache *s;
> +	unsigned long offset;
> +
> +	/* Find object. */
> +	s = page->slab_cache;
> +
> +	/* Find offset within object. */
> +	offset = (ptr - page_address(page)) % s->size;
> +
> +	/* Allow address range falling entirely within object size. */
> +	if (offset <= s->object_size && n <= s->object_size - offset)
> +		return NULL;
> +
> +	return s->name;
> +}

I gave this a quick spin on powerpc, it blew up immediately :)

  Brought up 16 CPUs
  usercopy: kernel memory overwrite attempt detected to c0000001fe023868 (kmalloc-16) (9 bytes)
  CPU: 8 PID: 103 Comm: kdevtmpfs Not tainted 4.7.0-rc3-00098-g09d9556ae5d1 #55
  Call Trace:
  [c0000001fa0cfb40] [c0000000009bdbe8] dump_stack+0xb0/0xf0 (unreliable)
  [c0000001fa0cfb80] [c00000000029cf44] __check_object_size+0x74/0x320
  [c0000001fa0cfc00] [c00000000005d4d0] copy_from_user+0x60/0xd4
  [c0000001fa0cfc40] [c00000000022b6cc] memdup_user+0x5c/0xf0
  [c0000001fa0cfc80] [c00000000022b90c] strndup_user+0x7c/0x110
  [c0000001fa0cfcc0] [c0000000002d6c28] SyS_mount+0x58/0x180
  [c0000001fa0cfd10] [c0000000005ee908] devtmpfsd+0x98/0x210
  [c0000001fa0cfd80] [c0000000000df810] kthread+0x110/0x130
  [c0000001fa0cfe30] [c0000000000095e8] ret_from_kernel_thread+0x5c/0x74

SLUB tracing says:

  TRACE kmalloc-16 alloc 0xc0000001fe023868 inuse=186 fp=0x          (null)

Which is not 16-byte aligned, which seems to be caused by the red zone?
The following patch fixes it for me, but I don't know SLUB enough to say
if it's always correct.


diff --git a/mm/slub.c b/mm/slub.c
index 0c8ace04f075..66191ea4545a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3630,6 +3630,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	/* Find object. */
 	s = page->slab_cache;
 
+	/* Subtract red zone if enabled */
+	ptr = restore_red_left(s, ptr);
+
 	/* Find offset within object. */
 	offset = (ptr - page_address(page)) % s->size;
 
cheers
