Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 222CB6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 16:22:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so4027672lfd.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:22:02 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id q8si6289288wja.208.2016.05.24.13.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 13:22:00 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id q62so9408299wmg.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:22:00 -0700 (PDT)
Date: Tue, 24 May 2016 22:29:01 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v1 3/3] Add the extra_latent_entropy kernel parameter
Message-Id: <20160524222901.9c60f81a0e3a48df0654d5e6@gmail.com>
In-Reply-To: <CAGXu5jJgFujkiqBrb6k-VX8WHz8P3A__McKNOtRgGd-USuEyeQ@mail.gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com>
	<20160524001736.135ae3cdc101ecec3232a493@gmail.com>
	<CAGXu5jJgFujkiqBrb6k-VX8WHz8P3A__McKNOtRgGd-USuEyeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Tue, 24 May 2016 10:09:16 -0700
Kees Cook <keescook@chromium.org> wrote:

> On Mon, May 23, 2016 at 3:17 PM, Emese Revfy <re.emese@gmail.com> wrote:
> > @@ -1235,6 +1236,15 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  }
> >
> >  #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
> > +bool __meminitdata extra_latent_entropy;
> > +
> > +static int __init setup_extra_latent_entropy(char *str)
> > +{
> > +       extra_latent_entropy = true;
> > +       return 0;
> > +}
> > +early_param("extra_latent_entropy", setup_extra_latent_entropy);
> > +
> >  volatile u64 latent_entropy __latent_entropy;
> >  EXPORT_SYMBOL(latent_entropy);
> >  #endif
> > @@ -1254,6 +1264,19 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
> >         __ClearPageReserved(p);
> >         set_page_count(p, 0);
> >
> > +#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
> > +       if (extra_latent_entropy && !PageHighMem(page) && page_to_pfn(page) < 0x100000) {
> > +               u64 hash = 0;
> > +               size_t index, end = PAGE_SIZE * nr_pages / sizeof hash;
> > +               const u64 *data = lowmem_page_address(page);
> > +
> > +               for (index = 0; index < end; index++)
> > +                       hash ^= hash + data[index];
> > +               latent_entropy ^= hash;
> > +               add_device_randomness((const void *)&latent_entropy, sizeof(latent_entropy));
> > +       }
> > +#endif
> > +
> 
> We try to minimize #ifdefs in the .c code, so in this case, I think I
> would define "extra_latent_entropy" during an #else above so this "if"
> can be culled by the compiler automatically:
> 
> #else
> # define extra_latent_entropy false
> #endif
> 
> Others may have better suggestions to avoid the second #ifdef, but
> this seems the cleanest way to me to tie this to the earlier #ifdef.

Hi,

I think the best way would be if I removed all #ifdefs because
this is useful without the latent_entropy plugin.
I don't know wether the default value of extra_latent_entropy
should be true or false. I'll do some performance measurements.

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
