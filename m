Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 026E66B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 23:59:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so252935827pff.13
        for <linux-mm@kvack.org>; Thu, 25 May 2017 20:59:49 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id h19si13523560pgk.221.2017.05.25.20.59.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 20:59:49 -0700 (PDT)
Message-ID: <5927A7C5.7070403@huawei.com>
Date: Fri, 26 May 2017 11:57:57 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: fix mlock incorrent event account
References: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com> <20170525081330.GG12721@dhcp22.suse.cz> <5926E0C8.9050908@huawei.com> <20170525141945.GK12721@dhcp22.suse.cz>
In-Reply-To: <20170525141945.GK12721@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org

On 2017/5/25 22:19, Michal Hocko wrote:
> On Thu 25-05-17 21:48:56, zhong jiang wrote:
>> Hi Michal
>>
>> by a testcase, The patch is work as I think. The testcase is as follows.
>>
>> int main(void)
>> {
>>     char *map;
>>     int fd;
>>
>>     fd = open("test", O_CREAT|O_RDWR);
>>     unlink("test");
>>     ftruncate(fd, 4096);
>>     map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
>>     map[0] = 11;
>>     mlock(map, sizeof(fd));
> just a nit
> you probably wanted mlock(map, 4096)
>
>>     ftruncate(fd, 0);
>>     close(fd);
>>     munlock(map, sizeof(fd));
> similarly here
>
>>     munmap(map, 4096);
>>
>>     return 0;
>> }
>>
>> before:
>> unevictable_pgs_mlocked 10589
>> unevictable_pgs_munlocked 10588
>> unevictable_pgs_cleared 1
>>
>> apply the patch;
>> after:
>> unevictable_pgs_mlocked 9497
>> unevictable_pgs_munlocked 9497
>> unevictable_pgs_cleared 1
> OK, this is definitely useful for the changelog.
>
>> unmap_mapping_range unmap them,  page_remove_rmap will deal with
>> clear_page_mlock situation.  we clear page Mlock flag and successful
>> isolate the page,  the page will putback the evictable list. but it is not
>> record the munlock event.
> and this as well. I haven't checked that but it gives reviewers chance
> to understand your thinking much better so it is definitely useful.
> Mlock code is everything but straightforward.
>
 HI, Michal

 I will add the above info the chanelog. and resent it in v2.

 Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
