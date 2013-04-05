Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D168D6B012C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:08 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id o13so418135qaj.3
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 15:23:07 -0700 (PDT)
Message-ID: <515F4ECB.9050105@gmail.com>
Date: Fri, 05 Apr 2013 18:23:07 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] mbind: add hugepage migration code to mbind()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com> <20130325134926.GZ2154@dhcp22.suse.cz>
In-Reply-To: <20130325134926.GZ2154@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

>> -	if (!new_hpage)
>> +	/*
>> +	 * Getting a new hugepage with alloc_huge_page() (which can happen
>> +	 * when migration is caused by mbind()) can return ERR_PTR value,
>> +	 * so we need take care of the case here.
>> +	 */
>> +	if (!new_hpage || IS_ERR_VALUE(new_hpage))
>>  		return -ENOMEM;
> 
> Please no. get_new_page returns NULL or a page. You are hooking a wrong
> callback here. The error value doesn't make any sense here. IMO you
> should just wrap alloc_huge_page by something that returns NULL or page.

I suggest just opposite way. new_vma_page() always return ENOMEM, ENOSPC etc instad 
of NULL. and caller propegate it to userland.
I guess userland want to distingush why mbind was failed.

Anyway, If new_vma_page() have a change to return both NULL and -ENOMEM. That's a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
