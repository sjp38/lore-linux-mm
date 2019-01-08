Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC2698E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:14:40 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id o11so1145221vke.5
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:14:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x23sor40887910ual.39.2019.01.08.13.14.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 13:14:39 -0800 (PST)
Received: from mail-vk1-f176.google.com (mail-vk1-f176.google.com. [209.85.221.176])
        by smtp.gmail.com with ESMTPSA id j95sm34846151uad.6.2019.01.08.13.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 13:14:37 -0800 (PST)
Received: by mail-vk1-f176.google.com with SMTP id y14so1212953vkd.1
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:14:37 -0800 (PST)
MIME-Version: 1.0
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
 <20190108114803.583f203b86d4a368ac9796f3@linux-foundation.org> <19c99d33-b796-72df-4212-20255f84efa0@c-s.fr>
In-Reply-To: <19c99d33-b796-72df-4212-20255f84efa0@c-s.fr>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 8 Jan 2019 13:14:25 -0800
Message-ID: <CAGXu5j+8XqMu596gtzRAjV=7cv2rThcE5-Wy6QTmNzdht3k66w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: add probe_user_read()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 8, 2019 at 1:11 PM Christophe Leroy <christophe.leroy@c-s.fr> w=
rote:
>
>
>
> Le 08/01/2019 =C3=A0 20:48, Andrew Morton a =C3=A9crit :
> > On Tue,  8 Jan 2019 07:37:44 +0000 (UTC) Christophe Leroy <christophe.l=
eroy@c-s.fr> wrote:
> >
> >> In powerpc code, there are several places implementing safe
> >> access to user data. This is sometimes implemented using
> >> probe_kernel_address() with additional access_ok() verification,
> >> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> >> pair, etc. :
> >>      show_user_instructions()
> >>      bad_stack_expansion()
> >>      p9_hmi_special_emu()
> >>      fsl_pci_mcheck_exception()
> >>      read_user_stack_64()
> >>      read_user_stack_32() on PPC64
> >>      read_user_stack_32() on PPC32
> >>      power_pmu_bhrb_to()
> >>
> >> In the same spirit as probe_kernel_read(), this patch adds
> >> probe_user_read().
> >>
> >> probe_user_read() does the same as probe_kernel_read() but
> >> first checks that it is really a user address.
> >>
> >> ...
> >>
> >> --- a/include/linux/uaccess.h
> >> +++ b/include/linux/uaccess.h
> >> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const =
void *unsafe_addr, long count);
> >>   #define probe_kernel_address(addr, retval)         \
> >>      probe_kernel_read(&retval, addr, sizeof(retval))
> >>
> >> +/**
> >> + * probe_user_read(): safely attempt to read from a user location
> >> + * @dst: pointer to the buffer that shall take the data
> >> + * @src: address to read from
> >> + * @size: size of the data chunk
> >> + *
> >> + * Returns: 0 on success, -EFAULT on error.
> >> + *
> >> + * Safely read from address @src to the buffer at @dst.  If a kernel =
fault
> >> + * happens, handle that and return -EFAULT.
> >> + *
> >> + * We ensure that the copy_from_user is executed in atomic context so=
 that
> >> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> >> + * probe_user_read() suitable for use within regions where the caller
> >> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> >> + */
> >> +
> >> +#ifndef probe_user_read
> >> +static __always_inline long probe_user_read(void *dst, const void __u=
ser *src,
> >> +                                        size_t size)
> >> +{
> >> +    long ret;
> >> +
> >> +    if (!access_ok(src, size))
> >> +            return -EFAULT;
> >> +
> >> +    pagefault_disable();
> >> +    ret =3D __copy_from_user_inatomic(dst, src, size);
> >> +    pagefault_enable();
> >> +
> >> +    return ret ? -EFAULT : 0;
> >> +}
> >> +#endif
> >
> > Why was the __always_inline needed?
> >
> > This function is pretty large.  Why is it inlined?
> >
>
> Kees told to do that way, see https://patchwork.ozlabs.org/patch/986848/

Yeah, I'd like to make sure we can plumb the size checks down into the
user copy primitives.

--=20
Kees Cook
