Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3C05C6B003D
	for <linux-mm@kvack.org>; Sat, 12 Dec 2009 08:06:55 -0500 (EST)
Received: by fxm9 with SMTP id 9so1787460fxm.10
        for <linux-mm@kvack.org>; Sat, 12 Dec 2009 05:06:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091212125046.14df3134.d-nishimura@mtf.biglobe.ne.jp>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	 <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	 <20091212125046.14df3134.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 12 Dec 2009 15:06:52 +0200
Message-ID: <cc557aab0912120506x56b9a707ob556035fdcf40a22@mail.gmail.com>
Subject: Re: [PATCH RFC v2 3/4] memcg: rework usage of stats by soft limit
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 12, 2009 at 5:50 AM, Daisuke Nishimura
<d-nishimura@mtf.biglobe.ne.jp> wrote:
> Sorry, I disagree this change.
>
> mem_cgroup_soft_limit_check() is used for checking how much current usage=
 exceeds
> the soft_limit_in_bytes and updating softlimit tree asynchronously, inste=
ad of
> checking every charge/uncharge. What if you change the soft_limit_in_byte=
s,
> but the number of charges and uncharges are very balanced afterwards ?
> The softlimit tree will not be updated for a long time.

I don't see how my patch affects the logic you've described.
Statistics updates and
checks in the same place. It just uses decrement instead of increment.

>
> And IIUC, it's the same for your threshold feature, right ?
> I think it would be better:
>
> - discard this change.
> - in 4/4, rename mem_cgroup_soft_limit_check to mem_cgroup_event_check,
> =C2=A0and instead of adding a new STAT counter, do like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_event_check(mem)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_update_=
tree(mem, page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_thresho=
ld(mem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}

I think that mem_cgroup_update_tree() and mem_cgroup_threshold() should be
run with different frequency. How to share MEM_CGROUP_STAT_EVENTS
between soft limits and thresholds in this case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
