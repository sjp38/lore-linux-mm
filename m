Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 64A399000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 02:00:55 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p8M60i4C024021
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 23:00:50 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz21.hot.corp.google.com with ESMTP id p8M5xIXn011384
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 23:00:38 -0700
Received: by qyk7 with SMTP id 7so2458807qyk.19
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 23:00:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E7A342B.5040608@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
 <1316393805-3005-3-git-send-email-glommer@parallels.com> <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
 <4E7A342B.5040608@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 21 Sep 2011 23:00:18 -0700
Message-ID: <CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com>
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Wed, Sep 21, 2011 at 11:59 AM, Glauber Costa <glommer@parallels.com> wrote:
> Right now I am working under the assumption that tasks are long lived inside
> the cgroup. Migration potentially introduces some nasty locking problems in
> the mem_schedule path.
>
> Also, unless I am missing something, the memcg already has the policy of
> not carrying charges around, probably because of this very same complexity.
>
> True that at least it won't EBUSY you... But I think this is at least a way
> to guarantee that the cgroup under our nose won't disappear in the middle of
> our allocations.

Here's the memcg user page behavior using the same pattern:

1. user page P is allocate by task T in memcg M1
2. T is moved to memcg M2.  The P charge is left behind still charged
to M1 if memory.move_charge_at_immigrate=0; or the charge is moved to
M2 if memory.move_charge_at_immigrate=1.
3. rmdir M1 will try to reclaim P (if P was left in M1).  If unable to
reclaim, then P is recharged to parent(M1).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
