Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AED8831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 12:56:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 36so56078620qkz.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 09:56:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j31si18285234qtb.91.2017.05.22.09.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 09:56:14 -0700 (PDT)
Subject: Re: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal process
 constraint
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-13-git-send-email-longman@redhat.com>
 <20170519203824.GC15279@wtj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <93a69664-4ba6-9ee8-e4ea-ce76b6682c77@redhat.com>
Date: Mon, 22 May 2017 12:56:08 -0400
MIME-Version: 1.0
In-Reply-To: <20170519203824.GC15279@wtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/19/2017 04:38 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Mon, May 15, 2017 at 09:34:11AM -0400, Waiman Long wrote:
>> The rationale behind the cgroup v2 no internal process constraint is
>> to avoid resouorce competition between internal processes and child
>> cgroups. However, not all controllers have problem with internal
>> process competiton. Enforcing this rule may lead to unnatural process
>> hierarchy and unneeded levels for those controllers.
> This isn't necessarily something we can determine by looking at the
> current state of controllers.  It's true that some controllers - pid
> and perf - inherently only care about membership of each task but at
> the same time neither really suffers from the constraint either.  CPU
> which is the problematic one here and currently only cares about tasks
> actually distributes resources which have parts which are specific to
> domain rather than threads and we don't want to declare that CPU isn't
> domain aware resource because it inherently is.

I agree that it is hard to decide which controller should be regarded as
domain aware and which should not be. That is why I don't attempt to do
that in the v2 patchset.

Unlike my v1 patch where each controller has to be specifically marked
as being a resource domain and hence has special directory for internal
process resource control knobs, the v2 patch leaves the decision up to
the userland. Depending on the context, any controllers can now have
special resource control knobs for internal processes in the
cgroup.resource_domain directory by writing the controller name to the
cgroup.resource_control file. So even the CPU controller can be regarded
as domain aware, if necessary. This is all part of my move to give as
much freedom and flexibility to the userland.

>> This patch removes the no internal process contraint by enabling those=

>> controllers that don't like internal process competition to have a
>> separate set of control knobs just for internal processes in a cgroup.=

>>
>> A new control file "cgroup.resource_control" is added. Enabling a
>> controller with a "+" prefix will create a separate set of control
>> knobs for that controller in the special "cgroup.resource_domain"
>> sub-directory for all the internal processes. The existing control
>> knobs in the cgroup will then be used to manage resource distribution
>> between internal processes as a group and other child cgroups.
> We would need to declare all major resource controllers to be needing
> that special sub-directory.  That'd work around the
> no-internal-process constraint but I don't think it is solving any
> real problems.  It's just the kernel doing something that userland can
> do with ease and more context.

All controllers can use the special sub-directory if userland chooses to
do so. The problem that I am trying to address in this patch is to allow
more natural hierarchy that reflect a certain purpose, like the task
classification done by systemd. Restricting tasks only to leaf nodes
makes the hierarchy unnatural and probably difficult to manage.

Regards,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
