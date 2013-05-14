Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 779006B0070
	for <linux-mm@kvack.org>; Tue, 14 May 2013 04:35:20 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg9so130427bkc.6
        for <linux-mm@kvack.org>; Tue, 14 May 2013 01:35:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130513131251.GB5246@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
	<1368421545-4974-1-git-send-email-handai.szj@taobao.com>
	<20130513131251.GB5246@dhcp22.suse.cz>
Date: Tue, 14 May 2013 16:35:18 +0800
Message-ID: <CAFj3OHXFABe=M7sns16UDs5hchfyoAkOwmxdNRa=jm_e0k-V9A@mail.gmail.com>
Subject: Re: [PATCH V2 3/3] memcg: simplify lock of memcg page stat account
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: multipart/alternative; boundary=485b3970d29a635bcc04dca9836c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Sha Zhengju <handai.szj@taobao.com>

--485b3970d29a635bcc04dca9836c
Content-Type: text/plain; charset=ISO-8859-1

Hi Michal,

Thank you for reviewing the patch from your busy work!

On Mon, May 13, 2013 at 9:12 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 13-05-13 13:05:44, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> After removing duplicated information like PCG_* flags in
>> 'struct page_cgroup'(commit 2ff76f1193), there's a problem between
>> "move" and "page stat accounting"(only FILE_MAPPED is supported now
>> but other stats will be added in future, and here I'd like to take
>> dirty page as an example):
>>
>> Assume CPU-A does "page stat accounting" and CPU-B does "move"
>>
>> CPU-A                        CPU-B
>> TestSet PG_dirty
>> (delay)               move_lock_mem_cgroup()
>>                         if (PageDirty(page)) {
>>                              old_memcg->nr_dirty --
>>                              new_memcg->nr_dirty++
>>                         }
>>                         pc->mem_cgroup = new_memcg;
>>                         move_unlock_mem_cgroup()
>>
>> move_lock_mem_cgroup()
>> memcg = pc->mem_cgroup
>> memcg->nr_dirty++
>> move_unlock_mem_cgroup()
>>
>> while accounting information of new_memcg may be double-counted. So we
>> use a bigger lock to solve this problem:  (commit: 89c06bd52f)
>>
>>       move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
>>       TestSetPageDirty(page)
>>       update page stats (without any checks)
>>       move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
>>
>>
>> But this method also has its pros and cons: at present we use two layers
>> of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
>> on memcg (see mem_cgroup_begin_update_page_stat()), but the lock
>> granularity is a little bigger that not only the critical section but
>> also some code logic is in the range of locking which may be deadlock
>> prone. While trying to add memcg dirty page accounting, it gets into
>> further difficulty with page cache radix-tree lock and even worse
>> mem_cgroup_begin_update_page_stat() requires nesting
>> (https://lkml.org/lkml/2013/1/2/48). However, when the current patch is
>> preparing, the lock nesting problem is longer possible as s390/mm has
>> reworked it out(commit:abf09bed), but it should be better
>> if we can make the lock simpler and recursive safe.
>
> This patch doesn't make the charge move locking recursive safe. It
> just tries to overcome the problem in the path where it doesn't exist
> anymore. mem_cgroup_begin_update_page_stat would still deadlock if it
> was re-entered.

Referring to deadlock or recursive, I think one of the reasons is that the
scope of lock is too large and includes some complicated codes in. So this
patch is trying to make lock regions as small as possible to lower
possibility of recursion. Yeah, mem_cgroup_begin_update_page_stat still
can't re-entered after this patch, but if we can avoid re-enter calls at
the very beginning, it can also solve our problem, doesn't it?

>
> It makes PageCgroupUsed usage even more tricky because it uses it out of
> lock_page_cgroup context. It seems that this would work in this

This is why I investigate all those four to find whether using
PageCgroupUsed here is race safe... it's really a little trick to be
honest...

> particular path because atomic_inc_and_test(_mapcount) will protect from
> double accounting but the whole dance around old_memcg seems pointless
> to me.

There's no problem with FILE_MAPPED accounting, it will be serialized by
page table lock.

>
> I am sorry but I do not think this is the right approach. IMO we should
> focus on mem_cgroup_begin_update_page_stat and make it really recursive
> safe - ideally without any additional overhead (which sounds like a real
> challenge)
>
> [...]
> --
> Michal Hocko
> SUSE Labs



Thanks,
Sha

--485b3970d29a635bcc04dca9836c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><br>Hi Michal,<br><br>Thank you for reviewing the pat=
ch from your busy work!<br><br>On Mon, May 13, 2013 at 9:12 PM, Michal Hock=
o &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>&g=
t; On Mon 13-05-13 13:05:44, Sha Zhengju wrote:<br>
&gt;&gt; From: Sha Zhengju &lt;<a href=3D"mailto:handai.szj@taobao.com">han=
dai.szj@taobao.com</a>&gt;<br>&gt;&gt;<br>&gt;&gt; After removing duplicate=
d information like PCG_* flags in<br>&gt;&gt; &#39;struct page_cgroup&#39;(=
commit 2ff76f1193), there&#39;s a problem between<br>
&gt;&gt; &quot;move&quot; and &quot;page stat accounting&quot;(only FILE_MA=
PPED is supported now<br>&gt;&gt; but other stats will be added in future, =
and here I&#39;d like to take<br>&gt;&gt; dirty page as an example):<br>
&gt;&gt;<br>&gt;&gt; Assume CPU-A does &quot;page stat accounting&quot; and=
 CPU-B does &quot;move&quot;<br>&gt;&gt;<br>&gt;&gt; CPU-A =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CPU-B<br>&gt;&gt; TestSet PG_dirty<br>&gt;&g=
t; (delay) =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_lock_mem_cgroup()<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageDirty(page=
)) {<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0old_memcg-&gt;nr_dirty --<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0new_memcg-&gt;nr_dirty++<br>&gt;&gt; =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc-&gt;mem_cgroup =
=3D new_memcg;<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
move_unlock_mem_cgroup()<br>&gt;&gt;<br>&gt;&gt; move_lock_mem_cgroup()<br>=
&gt;&gt; memcg =3D pc-&gt;mem_cgroup<br>&gt;&gt; memcg-&gt;nr_dirty++<br>
&gt;&gt; move_unlock_mem_cgroup()<br>&gt;&gt;<br>&gt;&gt; while accounting =
information of new_memcg may be double-counted. So we<br>&gt;&gt; use a big=
ger lock to solve this problem: =A0(commit: 89c06bd52f)<br>&gt;&gt;<br>&gt;=
&gt; =A0 =A0 =A0 move_lock_mem_cgroup() &lt;-- mem_cgroup_begin_update_page=
_stat()<br>
&gt;&gt; =A0 =A0 =A0 TestSetPageDirty(page)<br>&gt;&gt; =A0 =A0 =A0 update =
page stats (without any checks)<br>&gt;&gt; =A0 =A0 =A0 move_unlock_mem_cgr=
oup() &lt;-- mem_cgroup_begin_update_page_stat()<br>&gt;&gt;<br>&gt;&gt;<br=
>&gt;&gt; But this method also has its pros and cons: at present we use two=
 layers<br>
&gt;&gt; of lock avoidance(memcg_moving and memcg-&gt;moving_account) then =
spinlock<br>&gt;&gt; on memcg (see mem_cgroup_begin_update_page_stat()), bu=
t the lock<br>&gt;&gt; granularity is a little bigger that not only the cri=
tical section but<br>
&gt;&gt; also some code logic is in the range of locking which may be deadl=
ock<br>&gt;&gt; prone. While trying to add memcg dirty page accounting, it =
gets into<br>&gt;&gt; further difficulty with page cache radix-tree lock an=
d even worse<br>
&gt;&gt; mem_cgroup_begin_update_page_stat() requires nesting<br>&gt;&gt; (=
<a href=3D"https://lkml.org/lkml/2013/1/2/48">https://lkml.org/lkml/2013/1/=
2/48</a>). However, when the current patch is<br>&gt;&gt; preparing, the lo=
ck nesting problem is longer possible as s390/mm has<br>
&gt;&gt; reworked it out(commit:abf09bed), but it should be better<br>&gt;&=
gt; if we can make the lock simpler and recursive safe.<br>&gt;<br>&gt; Thi=
s patch doesn&#39;t make the charge move locking recursive safe. It<br>
&gt; just tries to overcome the problem in the path where it doesn&#39;t ex=
ist<br>&gt; anymore. mem_cgroup_begin_update_page_stat would still deadlock=
 if it<br>&gt; was re-entered.<br><br>Referring to deadlock or recursive, I=
 think one of the reasons is that the scope of lock is too large and includ=
es some complicated codes in. So this patch is trying to make lock regions =
as small as possible to lower possibility of recursion. Yeah, mem_cgroup_be=
gin_update_page_stat still can&#39;t re-entered after this patch, but if we=
 can avoid re-enter calls at the very beginning, it can also solve our prob=
lem, doesn&#39;t it?<br>
<br>&gt;<br>&gt; It makes PageCgroupUsed usage even more tricky because it =
uses it out of<br>&gt; lock_page_cgroup context. It seems that this would w=
ork in this<br><br>This is why I investigate all those four to find whether=
 using PageCgroupUsed here is race safe... it&#39;s really a little trick t=
o be honest... <br>
<br>&gt; particular path because atomic_inc_and_test(_mapcount) will protec=
t from<br>&gt; double accounting but the whole dance around old_memcg seems=
 pointless<br>&gt; to me.<br><br></div>There&#39;s no problem with FILE_MAP=
PED accounting, it will be serialized by page table lock.<br>
<br><div>&gt;<br>&gt; I am sorry but I do not think this is the right appro=
ach. IMO we should<br>&gt; focus on mem_cgroup_begin_update_page_stat and m=
ake it really recursive<br>&gt; safe - ideally without any additional overh=
ead (which sounds like a real<br>
&gt; challenge)<br>&gt;<br>&gt; [...]<br>&gt; --<br>&gt; Michal Hocko<br>&g=
t; SUSE Labs<br><br><br><br>Thanks,<br>Sha<br></div></div>

--485b3970d29a635bcc04dca9836c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
