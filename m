Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD8BE6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:55:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so859224993pfy.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:55:08 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j1si80137648pli.211.2017.01.06.08.55.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 08:55:08 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <d234fb8b-965f-d966-46fe-965478fdf7cb@linux.intel.com>
 <8612e7db-97c5-f757-0aae-24c3acedbc29@oracle.com>
 <2c0502d0-20ef-44ac-db5b-7f651a70b978@linux.intel.com>
 <ba9c4de2-cec1-1c88-82c9-24a524eb7948@oracle.com>
 <db31d324-a1ae-7450-0e54-ad98da205773@linux.intel.com>
 <5a0270ea-b29a-0751-a27f-2412a8588561@oracle.com>
 <7532a1d6-6562-b10b-dacd-931cb2a9e536@linux.intel.com>
 <92d55a69-b400-8461-53a1-d505de089700@oracle.com>
 <75c31c99-cff7-72dc-f593-012fe5acd405@linux.intel.com>
 <7fbc4ca1-22ef-8ef5-5c1b-dd075852e512@oracle.com>
 <20170106091934.GF5556@dhcp22.suse.cz>
 <ac86aa55-964d-56a1-1381-c208de78b24e@oracle.com>
 <f33f2c3c-4ec5-423c-5d13-a4b9ab8f7a95@linux.intel.com>
 <cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b761e7a9-6f64-e8cb-334a-a49528e95cdf@linux.intel.com>
Date: Fri, 6 Jan 2017 08:55:03 -0800
MIME-Version: 1.0
In-Reply-To: <cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: Rob Gardner <rob.gardner@oracle.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/06/2017 08:22 AM, Khalid Aziz wrote:
> On 01/06/2017 08:36 AM, Dave Hansen wrote:
>> On 01/06/2017 07:32 AM, Khalid Aziz wrote:
>>> I agree with you on simplicity first. Subpage granularity is complex,
>>> but the architecture allows for subpage granularity. Maybe the right
>>> approach is to support this at page granularity first for swappable
>>> pages and then expand to subpage granularity in a subsequent patch?
>>> Pages locked in memory can already use subpage granularity with my
>>> patch.
>>
>> What do you mean by "locked in memory"?  mlock()'d memory can still be
>> migrated around and still requires "swap" ptes, for instance.
> 
> You are right. Page migration can invalidate subpage granularity even
> for locked pages. Is it possible to use cpusets to keep a task and its
> memory locked on a single node?

It's going to be hard to impossible to guarantee.  mlock() doesn't
guarantee that things won't change physical addresses.  You'd have to
change that guarantee or chase all the things in the kernel that might
change physical addresses (compaction, ksm, etc...).

Actually, that reminds me...  How does your code interface with ksm?  Or
is there no interaction needed since you're always working on virtual
addresses?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
