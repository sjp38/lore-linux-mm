Date: Sun, 23 Mar 2008 19:38:50 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] [2/18] Add basic support for more than one hstate in hugetlbfs
In-Reply-To: <20080317015815.D43991B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015815.D43991B41E0@basil.firstfloor.org>
Message-Id: <20080323193340.B31D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Hi Andi

sorry for very late review.

> @@ -497,11 +501,34 @@ static int __init hugetlb_init(void)
>  			break;
>  	}
>  	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> -	printk("Total HugeTLB memory allocated, %ld\n", h->free_huge_pages);
> +
> +	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
> +			h->free_huge_pages,
> +			1 << (h->order + PAGE_SHIFT - 20));
>  	return 0;
>  }

IA64 arch support 64k hugepage, assumption >1MB size is wrong.


> +/* Should be called on processing a hugepagesz=... option */
> +void __init huge_add_hstate(unsigned order)
> +{
> +	struct hstate *h;
> +	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
> +	BUG_ON(order <= HPAGE_SHIFT - PAGE_SHIFT);
> +	h = &hstates[max_hstate++];
> +	h->order = order;
> +	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
> +	hugetlb_init_hstate(h);
> +	parsed_hstate = h;
> +}

this function is called once by one boot parameter, right?
if so, this function cause panic when stupid user write many 
hugepagesz boot parameter.

Why don't you use following check.

 if (max_hstate >= HUGE_MAX_HSTATE) {
     printk("hoge hoge");
     return;
 }



- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
