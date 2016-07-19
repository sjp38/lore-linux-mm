Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAC866B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:40:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so19735560wmp.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:40:49 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id u186si23021579wmg.3.2016.07.19.15.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:40:48 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id o80so43934882wme.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:40:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1468965604-25023-1-git-send-email-labbott@redhat.com>
References: <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
 <1468965604-25023-1-git-send-email-labbott@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jul 2016 15:40:46 -0700
Message-ID: <CAGXu5jLRkRMutEauAg7dWV9CeDP3nzE4d71Fqt6H2d7OHTy71w@mail.gmail.com>
Subject: Re: [PATCH] mm: Add is_migrate_cma_page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 19, 2016 at 3:00 PM, Laura Abbott <labbott@redhat.com> wrote:
> Code such as hardened user copy[1] needs a way to tell if a
> page is CMA or not. Add is_migrate_cma_page in a similar way
> to is_migrate_isolate_page.
>
> [1]http://article.gmane.org/gmane.linux.kernel.mm/155238
>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Great, thanks!

> ---
> Here's an explicit patch, slightly different than what I posted before. It can
> be kept separate or folded in as needed.

Assuming there's no objection, I'll add it to my tree and use the new macro.

-Kees

> ---
>  include/linux/mmzone.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 02069c2..c8478b2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -68,8 +68,10 @@ extern char * const migratetype_names[MIGRATE_TYPES];
>
>  #ifdef CONFIG_CMA
>  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> +#  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) == MIGRATE_CMA)
>  #else
>  #  define is_migrate_cma(migratetype) false
> +#  define is_migrate_cma_page(_page) false
>  #endif
>
>  #define for_each_migratetype_order(order, type) \
> --
> 2.7.4
>



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
