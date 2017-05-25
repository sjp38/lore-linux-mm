Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D05C6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 09:50:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x184so43016721wmf.14
        for <linux-mm@kvack.org>; Thu, 25 May 2017 06:50:21 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id a90si10302543wmi.8.2017.05.25.06.50.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 06:50:19 -0700 (PDT)
Message-ID: <5926E0C8.9050908@huawei.com>
Date: Thu, 25 May 2017 21:48:56 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: fix mlock incorrent event account
References: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com> <20170525081330.GG12721@dhcp22.suse.cz>
In-Reply-To: <20170525081330.GG12721@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org

Hi Michal

by a testcase, The patch is work as I think. The testcase is as follows.

int main(void)
{
    char *map;
    int fd;

    fd = open("test", O_CREAT|O_RDWR);
    unlink("test");
    ftruncate(fd, 4096);
    map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
    map[0] = 11;
    mlock(map, sizeof(fd));
    ftruncate(fd, 0);
    close(fd);
    munlock(map, sizeof(fd));
    munmap(map, 4096);

    return 0;
}

before:
unevictable_pgs_mlocked 10589
unevictable_pgs_munlocked 10588
unevictable_pgs_cleared 1

apply the patch;
after:
unevictable_pgs_mlocked 9497
unevictable_pgs_munlocked 9497
unevictable_pgs_cleared 1

unmap_mapping_range unmap them,  page_remove_rmap will deal with
clear_page_mlock situation.  we clear page Mlock flag and successful
isolate the page,  the page will putback the evictable list. but it is not
record the munlock event.

Thanks
zhongjiang

On 2017/5/25 16:13, Michal Hocko wrote:
> On Thu 25-05-17 15:59:39, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when clear_page_mlock call, we had finish the page isolate successfully,
>> but it fails to increase the UNEVICTABLE_PGMUNLOCKED account.
>>
>> The patch add the event account when successful page isolation.
> Could you describe _what_ is the problem, how it can be _triggered_
> and _how_ serious it is. Is it something that can be triggered from
> userspace? The mlock code is really tricky and it is far from trivial
> to see whether this is obviously right or a wrong assumption on your
> side. Before people go and spend time reviewing it is fair to introduce
> them to the problem.
>
> I believe this is not the first time I am giving you this feedback
> so I would _really_ appreciated if you tried harder with the changelog.
> It is much simpler to write a patch than review it in many cases.
>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/mlock.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index c483c5c..941930b 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -64,6 +64,7 @@ void clear_page_mlock(struct page *page)
>>  			    -hpage_nr_pages(page));
>>  	count_vm_event(UNEVICTABLE_PGCLEARED);
>>  	if (!isolate_lru_page(page)) {
>> +		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
>>  		putback_lru_page(page);
>>  	} else {
>>  		/*
>> -- 
>> 1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
