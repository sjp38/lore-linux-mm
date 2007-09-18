Message-ID: <46EF377D.4030004@redhat.com>
Date: Mon, 17 Sep 2007 22:27:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon() function
References: <20070914205359.6536.98017.sendpatchset@localhost>	<20070914205425.6536.69946.sendpatchset@localhost> <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 14 Sep 2007 16:54:25 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
>> +/*
>> + * Returns true if this page is anonymous, tmpfs or otherwise swap backed.
>> + */
>> +extern const struct address_space_operations shmem_aops;
>> +static inline int page_anon(struct page *page)
>> +{
>> +	struct address_space *mapping;
>> +
>> +	if (PageAnon(page) || PageSwapCache(page))
>> +		return 1;
>> +	mapping = page_mapping(page);
>> +	if (!mapping || !mapping->a_ops)
>> +		return 0;
>> +	if (mapping->a_ops == &shmem_aops)
>> +		return 1;
>> +	/* Should ramfs pages go onto an mlocked list instead? */
>> +	if ((unlikely(mapping->a_ops->writepage == NULL && PageDirty(page))))
>> +		return 1;
>> +
>> +	/* The page is page cache backed by a normal filesystem. */
>> +	return 0;
>> +}
>> +
> 
> Hi, it seems the name 'page_anon()' is not clear..
> In my understanding, an anonymous page is a MAP_ANONYMOUS page.
> Can't we have better name ?

The idea is to distinguish pages that are (or could be) swap backed
from pages that are filesystem backed.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
