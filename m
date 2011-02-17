Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BFAE68D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:50:23 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p1HNoMIn030515
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:50:22 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz24.hot.corp.google.com with ESMTP id p1HNnpqv013622
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:50:21 -0800
Received: by pzk26 with SMTP id 26so17618pzk.29
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:50:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110217144643.0d60bef4.akpm@linux-foundation.org>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com>
 <20110217144643.0d60bef4.akpm@linux-foundation.org>
From: Paul Menage <menage@google.com>
Date: Thu, 17 Feb 2011 15:50:01 -0800
Message-ID: <AANLkTin6TqQMHSpQjNXNrgGAHG8DL6CvzhTm3KHoxv0y@mail.gmail.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Thu, Feb 17, 2011 at 2:46 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 17 Feb 2011 09:50:09 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
>
>> +/*
>> + * In functions that can't propogate errno to users, to avoid declaring=
 a
>> + * nodemask_t variable, and avoid using NODEMASK_ALLOC that can return
>> + * -ENOMEM, we use this global cpuset_mems.
>> + *
>> + * It should be used with cgroup_lock held.
>
> I'll do s/should/must/ - that would be a nasty bug.
>
> I'd be more comfortable about the maintainability of this optimisation
> if we had
>
> =A0 =A0 =A0 =A0WARN_ON(!cgroup_is_locked());
>
> at each site.
>

Agreed - that was my first thought on reading the patch. How about:

static nodemask_t *cpuset_static_nodemask() {
  static nodemask_t nodemask;
  WARN_ON(!cgroup_is_locked());
  return &nodemask;
}

and then just call cpuset_static_nodemask() in the various locations
being patched?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
