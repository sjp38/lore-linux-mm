Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 59B8B6B003D
	for <linux-mm@kvack.org>; Sat, 12 Dec 2009 08:11:36 -0500 (EST)
Received: by fxm9 with SMTP id 9so1789659fxm.10
        for <linux-mm@kvack.org>; Sat, 12 Dec 2009 05:11:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091212121902.e95f9561.d-nishimura@mtf.biglobe.ne.jp>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	 <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	 <9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
	 <20091212121902.e95f9561.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 12 Dec 2009 15:11:33 +0200
Message-ID: <cc557aab0912120511r7c83e97di3f97d2bb5eae326c@mail.gmail.com>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 12, 2009 at 5:19 AM, Daisuke Nishimura
<d-nishimura@mtf.biglobe.ne.jp> wrote:
>> @@ -56,6 +61,7 @@ static int really_do_swap_account __initdata =3D 1; /*=
 for remember boot option*/
>>
>> =C2=A0static DEFINE_MUTEX(memcg_tasklist); /* can be hold under cgroup_m=
utex */
> This mutex has already removed in current mmotm.
> Please write a patch for memcg based on mmot.

Ok.

>
>> =C2=A0#define SOFTLIMIT_EVENTS_THRESH (1000)
>> +#define THRESHOLDS_EVENTS_THRESH (100)
>>
>> =C2=A0/*
>> =C2=A0 * Statistics for memory cgroup.
>
> (snip)
>
>> @@ -1363,6 +1395,11 @@ static int __mem_cgroup_try_charge(struct mm_stru=
ct *mm,
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> =C2=A0done:
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem, fa=
lse);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_swap_account)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
mem_cgroup_threshold(mem, true);
>> + =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0nomem:
>> =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
>> @@ -1906,6 +1943,11 @@ __mem_cgroup_uncharge_common(struct page *page, e=
num charge_type ctype)
>>
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem, fa=
lse);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_swap_account)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
mem_cgroup_threshold(mem, true);
>> + =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 /* at swapout, this memcg will be accessed to recor=
d to swap */
>> =C2=A0 =C2=A0 =C2=A0 if (ctype !=3D MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
> Can "if (do_swap_account)" check be moved into mem_cgroup_threshold ?

Ok, I'll move it. It will affect performance of
mem_cgroup_invalidate_thresholds(),
but I don't think that it's important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
