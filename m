Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B558F6B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 14:17:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w131so75262911qka.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 11:17:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w39si228123qtb.297.2017.05.24.11.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 11:17:55 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers
 control in cgroup v2
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-14-git-send-email-longman@redhat.com>
 <20170519205550.GD15279@wtj.duckdns.org>
 <6fe07727-e611-bfcd-8382-593a51bb4888@redhat.com>
 <20170524173144.GI24798@htj.duckdns.org>
 <29bc746d-f89b-3385-fd5c-314bcd22f9f7@redhat.com>
 <20170524175600.GL24798@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <c77c4f14-7979-b870-3358-d1691d1cee2d@redhat.com>
Date: Wed, 24 May 2017 14:17:50 -0400
MIME-Version: 1.0
In-Reply-To: <20170524175600.GL24798@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/24/2017 01:56 PM, Tejun Heo wrote:
> Hello,
>
> On Wed, May 24, 2017 at 01:49:46PM -0400, Waiman Long wrote:
>> What I am saying is as follows:
>>     / A
>> P - B
>>    \ C
>>
>> # echo +memory > P/cgroups.subtree_control
>> # echo -memory > P/A/cgroup.controllers
>> # echo "#memory" > P/B/cgroup.controllers
>>
>> The parent grants the memory controller to its children - A, B and C.
>> Child A has the memory controller explicitly disabled. Child B has the=

>> memory controller in pass-through mode, while child C has the memory
>> controller enabled by default. "echo +memory > cgroup.controllers" is
>> not allowed. There are 2 possible choices with regard to the '-' or '#=
'
>> prefixes. We can allow them before the grant from the parent or only
>> after that. In the former case, the state remains dormant until after
>> the grant from the parent.
> Ah, I see, you want cgroup.controllers to be able to mask available
> controllers by the parent.  Can you expand your example with further
> nesting and how #memory on cgroup.controllers would affect the nested
> descendant?
>
> Thanks.
>
I would allow enabling the controller in subtree_control if granted from
the parent and not explicitly disabled. IOW, both B and C can "echo
+memory" to their subtree_control to grant memory controller to their
children, but not A. A has to re-enable memory controller or set it to
pass-through mode before it can enable it in subtree_control. I need to
clarify that "echo +memory > cgroup.controllers" is allowed to re-enable
it, but not without the granting from its parent.

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
