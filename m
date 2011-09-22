Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 117499000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 11:10:01 -0400 (EDT)
Received: by fxh17 with SMTP id 17so3762220fxh.14
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 08:09:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-3-git-send-email-glommer@parallels.com>
	<CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
	<4E7A342B.5040608@parallels.com>
	<CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com>
Date: Thu, 22 Sep 2011 20:39:55 +0530
Message-ID: <CAKTCnz=59HuEg9T-USi5oKSK=F+vr2QxCA17+i-rGj73k49rzw@mail.gmail.com>
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Thu, Sep 22, 2011 at 11:30 AM, Greg Thelen <gthelen@google.com> wrote:
> On Wed, Sep 21, 2011 at 11:59 AM, Glauber Costa <glommer@parallels.com> w=
rote:
>> Right now I am working under the assumption that tasks are long lived in=
side
>> the cgroup. Migration potentially introduces some nasty locking problems=
 in
>> the mem_schedule path.
>>
>> Also, unless I am missing something, the memcg already has the policy of
>> not carrying charges around, probably because of this very same complexi=
ty.
>>
>> True that at least it won't EBUSY you... But I think this is at least a =
way
>> to guarantee that the cgroup under our nose won't disappear in the middl=
e of
>> our allocations.
>
> Here's the memcg user page behavior using the same pattern:
>
> 1. user page P is allocate by task T in memcg M1
> 2. T is moved to memcg M2. =A0The P charge is left behind still charged
> to M1 if memory.move_charge_at_immigrate=3D0; or the charge is moved to
> M2 if memory.move_charge_at_immigrate=3D1.
> 3. rmdir M1 will try to reclaim P (if P was left in M1). =A0If unable to
> reclaim, then P is recharged to parent(M1).
>

We also have some magic in page_referenced() to remove pages
referenced from different containers. What we do is try not to
penalize a cgroup if another cgroup is referencing this page and the
page under consideration is being reclaimed from the cgroup that
touched it.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
