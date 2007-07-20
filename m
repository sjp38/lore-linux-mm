Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l6KLSQRo002811
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 22:28:27 +0100
Received: from an-out-0708.google.com (ancc2.prod.google.com [10.100.29.2])
	by zps38.corp.google.com with ESMTP id l6KLSFe5030686
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:28:18 -0700
Received: by an-out-0708.google.com with SMTP id c2so210271anc
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:28:15 -0700 (PDT)
Message-ID: <6599ad830707201403n6a364514y601996145fa3714c@mail.gmail.com>
Date: Fri, 20 Jul 2007 14:03:36 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 4/8] Memory controller memory accounting (v3)
In-Reply-To: <20070720082440.20752.67223.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082440.20752.67223.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Eric W Biederman <ebiederm@xmission.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +void __always_inline unlock_meta_page(struct page *page)
> +{
> +       bit_spin_unlock(PG_metapage, &page->flags);
> +}

Maybe add a BUG_ON(!test_bit(PG_metapage, &page->flags)) at least for
development?

> +       mem = rcu_dereference(mm->mem_container);
> +       /*
> +        * For every charge from the container, increment reference
> +        * count
> +        */
> +       css_get(&mem->css);
> +       rcu_read_unlock();

It's not clear to me that this is safe.

If

> +
> +       /*
> +        * If we created the meta_page, we should free it on exceeding
> +        * the container limit.
> +        */
> +       if (res_counter_charge(&mem->res, 1)) {
> +               css_put(&mem->css);
> +               goto free_mp;
> +       }
> +
> +       lock_meta_page(page);
> +       /*
> +        * Check if somebody else beat us to allocating the meta_page
> +        */
> +       if (page_get_meta_page(page)) {

I think you need to add something like

  kfree(mp);
  mp = page_get_meta_page(page);

otherwise you're going to leak the new but unneeded metapage.

> +               atomic_inc(&mp->ref_cnt);
> +               res_counter_uncharge(&mem->res, 1);
> +               goto done;
> +       }
> +
> +       atomic_set(&mp->ref_cnt, 1);
> +       mp->mem_container = mem;
> +       mp->page = page;
> +       page_assign_meta_page(page, mp);

Would it make sense to have the "mp->page = page" be part of
page_assign_meta_page() for consistency?

> +err:
> +       unlock_meta_page(page);
> +       return -ENOMEM;

The only jump to err: is from a location where the metapage is already
unlocked. Maybe scrap err: and just do a return -ENOMEM when the
allocation fails?

> +out_uncharge:
> +       mem_container_uncharge(page_get_meta_page(page));

Wanting to call mem_container_uncharge() on a page and hence having to
call page_get_meta_page() seems to be more common than wanting to call
it on a meta page that you already have available. Maybe make
mem_container_uncharge() be a wrapper that take a struct page and does
something like mem_container_uncharge_mp(page_get_meta_page(page))
where mem_container_uncharge_mp() is the raw meta-page version?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
