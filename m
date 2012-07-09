Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 0CC2E6B006C
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 23:36:16 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so22432019pbb.14
        for <linux-mm@kvack.org>; Sun, 08 Jul 2012 20:36:16 -0700 (PDT)
Message-ID: <4FFA51AB.30203@gmail.com>
Date: Mon, 09 Jul 2012 11:36:11 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] memcg: add per cgroup writeback pages accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881562-5900-1-git-send-email-handai.szj@taobao.com> <20120708145309.GC18272@localhost>
In-Reply-To: <20120708145309.GC18272@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 07/08/2012 10:53 PM, Fengguang Wu wrote:
>> @@ -2245,7 +2252,10 @@ int test_set_page_writeback(struct page *page)
>>   {
>>   	struct address_space *mapping = page_mapping(page);
>>   	int ret;
>> +	bool locked;
>> +	unsigned long flags;
>>
>> +	mem_cgroup_begin_update_page_stat(page,&locked,&flags);
>>   	if (mapping) {
>>   		struct backing_dev_info *bdi = mapping->backing_dev_info;
>>   		unsigned long flags;
>> @@ -2272,6 +2282,8 @@ int test_set_page_writeback(struct page *page)
>>   	}
>>   	if (!ret)
>>   		account_page_writeback(page);
>> +
>> +	mem_cgroup_end_update_page_stat(page,&locked,&flags);
>>   	return ret;
>>
>>   }
> Where is the MEM_CGROUP_STAT_FILE_WRITEBACK increased?
>

It's in account_page_writeback().

  void account_page_writeback(struct page *page)
  {
+	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_WRITEBACK);
  	inc_zone_page_state(page, NR_WRITEBACK);
  }


There isn't a unified interface to dec/inc writeback accounting, so
I just follow that.
Maybe we can rework account_page_writeback() to also account
dec in?


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
