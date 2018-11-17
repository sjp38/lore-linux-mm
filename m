Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56E936B0D26
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 23:22:16 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v74so34318340qkb.21
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 20:22:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o187si5349422qkb.117.2018.11.16.20.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 20:22:15 -0800 (PST)
Date: Sat, 17 Nov 2018 12:22:08 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181117042208.GB18471@MiWiFi-R3L-srv>
References: <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <20181115131211.GP2653@MiWiFi-R3L-srv>
 <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116091409.GD14706@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/16/18 at 10:14am, Michal Hocko wrote:
> Could you try to apply this debugging patch on top please? It will dump
> stack trace for each reference count elevation for one page that fails
> to migrate after multiple passes.

Thanks, applied and fixed two code issues. The dmesg has been sent to
you privately, please check. The dmesg is overflow, if you need the
earlier message, I will retest.

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index b64ebf253381..f76e2c498f31 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -72,7 +72,7 @@ static inline int page_count(struct page *page)
        return atomic_read(&compound_head(page)->_refcount);
 }
 
-struct page *page_to_track;
+extern struct page *page_to_track;
 static inline void set_page_count(struct page *page, int v)
 {
        atomic_set(&page->_refcount, v);
diff --git a/mm/migrate.c b/mm/migrate.c
index 9b2e395a3d68..42c7499c43b9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1339,6 +1339,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 }
 
 struct page *page_to_track;
+EXPORT_SYMBOL_GPL(page_to_track);
 
 /*
  * migrate_pages - migrate the pages specified in a list, to the free pages

> 
> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> index 14d14beb1f7f..b64ebf253381 100644
> --- a/include/linux/page_ref.h
> +++ b/include/linux/page_ref.h
> @@ -72,9 +72,12 @@ static inline int page_count(struct page *page)
>  	return atomic_read(&compound_head(page)->_refcount);
>  }
>  
> +struct page *page_to_track;
>  static inline void set_page_count(struct page *page, int v)
>  {
>  	atomic_set(&page->_refcount, v);
> +	if (page == page_to_track)
> +		dump_stack();
>  	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
>  		__page_ref_set(page, v);
>  }
> @@ -91,6 +94,8 @@ static inline void init_page_count(struct page *page)
>  static inline void page_ref_add(struct page *page, int nr)
>  {
>  	atomic_add(nr, &page->_refcount);
> +	if (page == page_to_track)
> +		dump_stack();
>  	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>  		__page_ref_mod(page, nr);
>  }
> @@ -105,6 +110,8 @@ static inline void page_ref_sub(struct page *page, int nr)
>  static inline void page_ref_inc(struct page *page)
>  {
>  	atomic_inc(&page->_refcount);
> +	if (page == page_to_track)
> +		dump_stack();
>  	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>  		__page_ref_mod(page, 1);
>  }
> @@ -129,6 +136,8 @@ static inline int page_ref_inc_return(struct page *page)
>  {
>  	int ret = atomic_inc_return(&page->_refcount);
>  
> +	if (page == page_to_track)
> +		dump_stack();
>  	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
>  		__page_ref_mod_and_return(page, 1, ret);
>  	return ret;
> @@ -156,6 +165,8 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
>  {
>  	int ret = atomic_add_unless(&page->_refcount, nr, u);
>  
> +	if (page == page_to_track)
> +		dump_stack();
>  	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
>  		__page_ref_mod_unless(page, nr, ret);
>  	return ret;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..9b2e395a3d68 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1338,6 +1338,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	return rc;
>  }
>  
> +struct page *page_to_track;
> +
>  /*
>   * migrate_pages - migrate the pages specified in a list, to the free pages
>   *		   supplied as the target for the page migration
> @@ -1375,6 +1377,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  	if (!swapwrite)
>  		current->flags |= PF_SWAPWRITE;
>  
> +	page_to_track = NULL;
>  	for(pass = 0; pass < 10 && retry; pass++) {
>  		retry = 0;
>  
> @@ -1417,6 +1420,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  				goto out;
>  			case -EAGAIN:
>  				retry++;
> +				if (pass > 1 && !page_to_track)
> +					page_to_track = page;
>  				break;
>  			case MIGRATEPAGE_SUCCESS:
>  				nr_succeeded++;
> -- 
> Michal Hocko
> SUSE Labs
