Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 206846B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 21:52:16 -0500 (EST)
Message-ID: <50C942BE.20902@huawei.com>
Date: Thu, 13 Dec 2012 10:51:42 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: create hugetlb cgroup file in hugetlb_init
References: <50C83F97.3040009@huawei.com> <20121212101917.GD32081@dhcp22.suse.cz> <50C85FFD.10305@huawei.com> <20121212112329.GE32081@dhcp22.suse.cz>
In-Reply-To: <20121212112329.GE32081@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, tj@kernel.org, lizefan@huawei.com, aneesh.kumar@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, dhillf@gmail.com, Jiang Liu <liuj97@gmail.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

On 2012/12/12 19:23, Michal Hocko wrote:

> On Wed 12-12-12 18:44:13, Xishi Qiu wrote:
>> On 2012/12/12 18:19, Michal Hocko wrote:
>>
>>> On Wed 12-12-12 16:25:59, Jianguo Wu wrote:
>>>> Build kernel with CONFIG_HUGETLBFS=y,CONFIG_HUGETLB_PAGE=y
>>>> and CONFIG_CGROUP_HUGETLB=y, then specify hugepagesz=xx boot option,
>>>> system will boot fail.
>>>>
>>>> This failure is caused by following code path:
>>>> setup_hugepagesz
>>>> 	hugetlb_add_hstate
>>>> 		hugetlb_cgroup_file_init
>>>> 			cgroup_add_cftypes
>>>> 				kzalloc <--slab is *not available* yet
>>>>
>>>> For this path, slab is not available yet, so memory allocated will be
>>>> failed, and cause WARN_ON() in hugetlb_cgroup_file_init().
>>>>
>>>> So I move hugetlb_cgroup_file_init() into hugetlb_init().
>>>
>>> I do not think this is a good idea. hugetlb_init is in __init section as
>>> well so what guarantees that the slab is initialized by then? Isn't this
>>> just a good ordering that makes this working?
>>
>> Hi Michal,
>>
>> __initcall functions will be called in
>> start_kernel()
>> 	rest_init()  // -> slab is already
>> 		kernel_init()
>> 			kernel_init_freeable()
>> 				do_basic_setup()
>> 					do_initcalls()
>>
>> and setup_hugepagesz() will be called in
>> start_kernel()
>> 	parse_early_param()  // -> before mm_init() -> kmem_cache_init()
>>
>> Is this right?
> 
> Yes this is right. I just noticed that kmem_cache_init_late is an __init
> function as well and didn't realize it is called directly. Sorry about
> the confusion.
> Anyway I still think it would be a better idea to move the call into the
> hugetlb_cgroup_create callback where it is more logical IMO but now that

Hi Michal,

Thanks for your review and comments:).
hugetlb_cgroup_create is a callback of hugetlb_subsys,
and hugetlb_cgroup_file_init add h->cgroup_files to hugetlb_subsys,
so we cann't move hugetlb_cgroup_file_init into hugetlb_cgroup_create, right?

Thanks,
Jianguo wu

> I'm looking at other controllers (blk and kmem.tcp) they all do this from
> init calls as well. So it doesn't make sense to have hugetlb behave
> differently.
> 
> So
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
