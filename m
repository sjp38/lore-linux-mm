Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA7F66B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 11:34:53 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r126so153251000oib.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 08:34:53 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id b12si5868106iob.62.2016.09.15.08.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 08:34:27 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id 186so80651952itf.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 08:34:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473759914-17003-4-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com> <1473759914-17003-4-git-send-email-byungchul.park@lge.com>
From: Nilay Vaish <nilayvaish@gmail.com>
Date: Thu, 15 Sep 2016 10:33:46 -0500
Message-ID: <CACbG308kitsX23FTCJiUDVpN2uusabHiN1ifao53yR5fM4Z7VA@mail.gmail.com>
Subject: Re: [PATCH v3 03/15] lockdep: Refactor lookup_chain_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> @@ -2215,6 +2178,75 @@ cache_hit:
>         return 1;
>  }
>
> +/*
> + * Look up a dependency chain.
> + */
> +static inline struct lock_chain *lookup_chain_cache(u64 chain_key)
> +{
> +       struct hlist_head *hash_head = chainhashentry(chain_key);
> +       struct lock_chain *chain;
> +
> +       /*
> +        * We can walk it lock-free, because entries only get added
> +        * to the hash:
> +        */
> +       hlist_for_each_entry_rcu(chain, hash_head, entry) {
> +               if (chain->chain_key == chain_key) {
> +                       debug_atomic_inc(chain_lookup_hits);
> +                       return chain;
> +               }
> +       }
> +       return NULL;
> +}

Byungchul,  do you think we should increment chain_lookup_misses
before returning NULL from the above function?

--
Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
