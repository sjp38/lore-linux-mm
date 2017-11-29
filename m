Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4D96B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:26:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m9so2462748pff.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:26:54 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u10si1268238plu.512.2017.11.29.05.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 05:26:53 -0800 (PST)
Message-ID: <5A1EB57B.2080101@huawei.com>
Date: Wed, 29 Nov 2017 21:26:19 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/numa: move setting parse numa node to num_add_memblk
References: <1511946807-22024-1-git-send-email-zhongjiang@huawei.com> <20171129120328.dfbr26o4wsjpwct3@dhcp22.suse.cz> <5A1EAAF5.4040602@huawei.com> <20171129130158.hji24remijkaoydb@dhcp22.suse.cz>
In-Reply-To: <20171129130158.hji24remijkaoydb@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, richard.weiyang@gmail.com, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On 2017/11/29 21:01, Michal Hocko wrote:
> On Wed 29-11-17 20:41:25, zhong jiang wrote:
>> On 2017/11/29 20:03, Michal Hocko wrote:
>>> On Wed 29-11-17 17:13:27, zhong jiang wrote:
>>>> Currently, Arm64 and x86 use the common code wehn parsing numa node
>>>> in a acpi way. The arm64 will set the parsed node in numa_add_memblk,
>>>> but the x86 is not set in that , then it will result in the repeatly
>>>> setting. And the parsed node maybe is  unreasonable to the system.
>>>>
>>>> we would better not set it although it also still works. because the
>>>> parsed node is unresonable. so we should skip related operate in this
>>>> node. This patch just set node in various architecture individually.
>>>> it is no functional change.
>>> I really have hard time to understand what you try to say above. Could
>>> you start by the problem description and then how you are addressing it?
>>   I am so sorry for that.  I will make the issue clear.
>>  
>>   Arm64  get numa information through acpi.  The code flow is as follows.
>>
>>   arm64_acpi_numa_init
>>        acpi_parse_memory_affinity
>>           acpi_numa_memory_affinity_init
>>               numa_add_memblk(nid, start, end);      //it will set node to numa_nodes_parsed successfully.
>>               node_set(node, numa_nodes_parsed);     // numa_add_memblk had set that.  it will repeat.
>>
>>  the root cause is that X86 parse numa also  go through above code.  and  arch-related
>>  numa_add_memblk  is not set the parsed node to numa_nodes_parsed.  it need
>>  additional node_set(node, numa_parsed) to handle.  therefore,  the issue will be introduced.
>>
> No it is not much more clear. I would have to go and re-study the whole
> code flow to see what you mean here. So you could simply state what _the
> issue_ is? How can user observe it and what are the consequences?
  The patch do not fix a real issue.  it is a cleanup.
  because the acpi code  is public,  I find they are messy between
  Arch64 and X86 when parsing numa message .  therefore,  I try to
  make the code more clear between them.

  Thanks
  zhongjiang
> Sorry for my laziness, I could go and read the code but the primary
> point of the changelog is to be _clear_ about the problem and the fix.
> Call paths can help reviewers but the scope should be clear even without
> them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
