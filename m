Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 933B76B03B8
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 08:13:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 56so7487388wrx.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 05:13:16 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id a17si32095999wrc.296.2017.06.06.05.13.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 05:13:15 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
References: <71e91de0-7d91-79f4-67f0-be0afb33583c@schaufler-ca.com>
 <201706060550.HAC69712.OVFOtSFLQJOMFH@I-love.SAKURA.ne.jp>
 <ff5714b2-bbb0-726d-2fe6-13d4f1a30a38@huawei.com>
 <201706061954.GBH56755.QSOOFMFLtJFVOH@I-love.SAKURA.ne.jp>
 <6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
 <201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4c3e3b8b-6507-7da5-1537-1e0ce04fcba5@huawei.com>
Date: Tue, 6 Jun 2017 15:11:58 +0300
MIME-Version: 1.0
In-Reply-To: <201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, casey@schaufler-ca.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 06/06/17 14:42, Tetsuo Handa wrote:
> Igor Stoppa wrote:
>> Who decides when enough is enough, meaning that all the needed modules
>> are loaded?
>> Should I provide an interface to user-space? A sysfs entry?
> 
> No such interface is needed. Just an API for applying set_memory_rw()
> and set_memory_ro() on LSM hooks is enough.
> 
> security_add_hooks() can call set_memory_rw() before adding hooks and
> call set_memory_ro() after adding hooks. Ditto for security_delete_hooks()
> for SELinux's unregistration.


I think this should be considered part of the 2nd phase "write seldom",
as we agreed with Kees Cook.

Right now the goal was to provide the basic API for:
- create pool
- get memory from pool
- lock the pool
- destroy the pool

And, behind the scene, verify that a memory range falls into Pmalloc pages.


Then would come the "write seldom" part.

The reason for this is that a proper implementation of write seldom
should, imho, make writable only those pages that really need to be
modified. Possibly also add some verification on the call stack about
who is requesting the unlocking.

Therefore I would feel more comfortable in splitting the work into 2 part.

For the case at hand, would it work if there was a non-API call that you
could use until the API is properly expanded?

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
