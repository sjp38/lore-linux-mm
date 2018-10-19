Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4EB86B0007
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 11:42:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 123-v6so3304870ywt.12
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 08:42:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x124-v6sor2929720ywa.149.2018.10.19.08.42.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 08:42:16 -0700 (PDT)
Received: from mail-yw1-f43.google.com (mail-yw1-f43.google.com. [209.85.161.43])
        by smtp.gmail.com with ESMTPSA id 200-v6sm5930819ywq.97.2018.10.19.08.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 08:42:14 -0700 (PDT)
Received: by mail-yw1-f43.google.com with SMTP id d126-v6so13355434ywa.5
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 08:42:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <336eb81e62d6c683a69d312f533899dcb6bcf770.1539959864.git.christophe.leroy@c-s.fr>
References: <336eb81e62d6c683a69d312f533899dcb6bcf770.1539959864.git.christophe.leroy@c-s.fr>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 19 Oct 2018 08:42:12 -0700
Message-ID: <CAGXu5jJzp0v_Ox4gJcSdMVT7Rzuoy4mH-J3tPfrpeyCTi4o5YQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: add probe_user_read() and probe_user_address()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, LKML <linux-kernel@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Oct 19, 2018 at 8:14 AM, Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> In the powerpc, there are several places implementing safe
> access to user data. This is sometimes implemented using
> probe_kerne_address() with additional access_ok() verification,
> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> pair, etc... :
>     show_user_instructions()
>     bad_stack_expansion()
>     p9_hmi_special_emu()
>     fsl_pci_mcheck_exception()
>     read_user_stack_64()
>     read_user_stack_32() on PPC64
>     read_user_stack_32() on PPC32
>     power_pmu_bhrb_to()
>
> In the same spirit as probe_kernel_read() and probe_kernel_address(),
> this patch adds probe_user_read() and probe_user_address().
>
> probe_user_read() does the same as probe_kernel_read() but
> first checks that it is really a user address.
>
> probe_user_address() is a shortcut to probe_user_read()
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  include/linux/uaccess.h | 10 ++++++++++
>  mm/maccess.c            | 33 +++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+)
>
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index efe79c1cdd47..fb00e3f847d7 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -266,6 +266,16 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>  #define probe_kernel_address(addr, retval)             \
>         probe_kernel_read(&retval, addr, sizeof(retval))
>
> +/**
> + * probe_user_address(): safely attempt to read from a user location
> + * @addr: address to read from
> + * @retval: read into this variable
> + *
> + * Returns 0 on success, or -EFAULT.
> + */
> +#define probe_user_address(addr, retval)               \
> +       probe_user_read(&(retval), addr, sizeof(retval))
> +
>  #ifndef user_access_begin
>  #define user_access_begin() do { } while (0)
>  #define user_access_end() do { } while (0)
> diff --git a/mm/maccess.c b/mm/maccess.c
> index ec00be51a24f..85d4a88a6917 100644
> --- a/mm/maccess.c
> +++ b/mm/maccess.c
> @@ -67,6 +67,39 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
>  EXPORT_SYMBOL_GPL(probe_kernel_write);
>
>  /**
> + * probe_user_read(): safely attempt to read from a user location
> + * @dst: pointer to the buffer that shall take the data
> + * @src: address to read from
> + * @size: size of the data chunk
> + *
> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
> + * happens, handle that and return -EFAULT.
> + *
> + * We ensure that the copy_from_user is executed in atomic context so that
> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> + * probe_user_read() suitable for use within regions where the caller
> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> + */
> +
> +long __weak probe_user_read(void *dst, const void *src, size_t size)
> +       __attribute__((alias("__probe_user_read")));

Let's use #defines to deal with per-arch aliases so we can keep the
inline I'm suggesting below...

> +
> +long __probe_user_read(void *dst, const void __user *src, size_t size)

Please make this __always_inline so the "size" variable can be
examined for const-ness by the check_object_size() in
__copy_from_user_inatomic().

-Kees

-- 
Kees Cook
Pixel Security
