Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4E96B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 23:41:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w74so2418110wmf.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 20:41:06 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j30si269370edb.274.2017.11.29.20.41.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 20:41:05 -0800 (PST)
Message-ID: <5A1F8B7B.9050505@huawei.com>
Date: Thu, 30 Nov 2017 12:39:23 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/numa: move setting parse numa node to num_add_memblk
References: <1511946807-22024-1-git-send-email-zhongjiang@huawei.com> <20171129120328.dfbr26o4wsjpwct3@dhcp22.suse.cz> <5A1EAAF5.4040602@huawei.com> <20171129130158.hji24remijkaoydb@dhcp22.suse.cz> <5A1EB57B.2080101@huawei.com> <20171129133355.ybbhzpqhmjreyofi@dhcp22.suse.cz> <5A1EB9B1.9000907@huawei.com> <496c8895-ea17-b7c0-3ea4-df555ebc2edc@cn.fujitsu.com>
In-Reply-To: <496c8895-ea17-b7c0-3ea4-df555ebc2edc@cn.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Michal Hocko <mhocko@kernel.org>, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, richard.weiyang@gmail.com, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On 2017/11/29 22:14, Dou Liyang wrote:
> Hi Jiang,
>
> At 11/29/2017 09:44 PM, zhong jiang wrote:
>> On 2017/11/29 21:33, Michal Hocko wrote:
>>> On Wed 29-11-17 21:26:19, zhong jiang wrote:
>>>> On 2017/11/29 21:01, Michal Hocko wrote:
>>>>> On Wed 29-11-17 20:41:25, zhong jiang wrote:
>>>>>> On 2017/11/29 20:03, Michal Hocko wrote:
>>>>>>> On Wed 29-11-17 17:13:27, zhong jiang wrote:
>>>>>>>> Currently, Arm64 and x86 use the common code wehn parsing numa node
>>>>>>>> in a acpi way. The arm64 will set the parsed node in numa_add_memblk,
>>>>>>>> but the x86 is not set in that , then it will result in the repeatly
>>>>>>>> setting. And the parsed node maybe is  unreasonable to the system.
>>>>>>>>
>>>>>>>> we would better not set it although it also still works. because the
>>>>>>>> parsed node is unresonable. so we should skip related operate in this
>>>>>>>> node. This patch just set node in various architecture individually.
>>>>>>>> it is no functional change.
>>>>>>> I really have hard time to understand what you try to say above. Could
>>>>>>> you start by the problem description and then how you are addressing it?
>>>>>>   I am so sorry for that.  I will make the issue clear.
>>>>>>
>>>>>>   Arm64  get numa information through acpi.  The code flow is as follows.
>>>>>>
>>>>>>   arm64_acpi_numa_init
>>>>>>        acpi_parse_memory_affinity
>>>>>>           acpi_numa_memory_affinity_init
>>>>>>               numa_add_memblk(nid, start, end);      //it will set node to numa_nodes_parsed successfully.
>>>>>>               node_set(node, numa_nodes_parsed);     // numa_add_memblk had set that.  it will repeat.
>>>>>>
>>>>>>  the root cause is that X86 parse numa also  go through above code.  and  arch-related
>>>>>>  numa_add_memblk  is not set the parsed node to numa_nodes_parsed.  it need
>>>>>>  additional node_set(node, numa_parsed) to handle.  therefore,  the issue will be introduced.
>>>>>>
>>>>> No it is not much more clear. I would have to go and re-study the whole
>>>>> code flow to see what you mean here. So you could simply state what _the
>>>>> issue_ is? How can user observe it and what are the consequences?
>>>>   The patch do not fix a real issue.  it is a cleanup.
>
> > @@ -294,7 +294,9 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
> >          goto out_err_bad_srat;
> >      }
> >
> > -    node_set(node, numa_nodes_parsed);
> > +    /* some architecture is likely to ignore a unreasonable node */
> > +    if (!node_isset(node, numa_nodes_parsed))
> > +        goto out;
> >
>
> It is not just a cleanup patch,    Here you change the original logic.
>
  you are right.  cleanup and slightly change.
> With this patch, we just set the *numa_nodes_parsed* after NUMA adds a
> memblk successfully and also add a check here for bypassing the invalid
> memblk node.
>
> I am not sure which arch may meet this situation? did you test this
> patch?
>
  At least  X86 maybe meet the condition. we can see the following code.

static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
                                     struct numa_meminfo *mi)
{
        /* ignore zero length blks */
        if (start == end)
                return 0;

        /* whine about and ignore invalid blks */
        if (start > end || nid < 0 || nid >= MAX_NUMNODES) {
                pr_warning("NUMA: Warning: invalid memblk node %d [mem %#010Lx-%#010Lx]\n",
                           nid, start, end - 1);
                return 0;
        }

        if (mi->nr_blks >= NR_NODE_MEMBLKS) {
                pr_err("NUMA: too many memblk ranges\n");
                return -EINVAL;
        }

        mi->blk[mi->nr_blks].start = start;
        mi->blk[mi->nr_blks].end = end;
        mi->blk[mi->nr_blks].nid = nid;
        mi->nr_blks++;
        return 0;
}

it is likely to fail and return 0.   e.g: start == end  etc.
In this case, we expect it should bail out in time.
> Anyway, AFAIK, The ACPI tables are very much like user input in that
> respect and they are unreasonable. So the patch is better.
>
  yes,  Totally agree. 

 Thanks
 zhong jiang
> Thanks,
>     dou.
>
>>>>   because the acpi code  is public,  I find they are messy between
>>>>   Arch64 and X86 when parsing numa message .  therefore,  I try to
>>>>   make the code more clear between them.
>>> So make this explicit in the changelog. Your previous wording sounded
>>> like there is a _problem_ in the code.
>>>
>> :-[       please take some time to check.  if it works.  I will resend v2 with detailed changelog.
>>
>> Thanks
>> zhongjiang
>>
>>
>>
>>
>
>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
