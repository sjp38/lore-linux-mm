Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB4366B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:02:22 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e8-v6so732349ioq.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 02:02:22 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id v126-v6si532109iod.82.2018.07.26.02.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 02:02:21 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <bug-200651-27@https.bugzilla.kernel.org/>
 <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
 <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
 <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
From: Georgi Nikolov <gnikolov@icdsoft.com>
Message-ID: <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
Date: Thu, 26 Jul 2018 12:02:03 +0300
MIME-Version: 1.0
In-Reply-To: <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
Content-Type: multipart/alternative;
 boundary="------------E7D7723C4105C974F53995DE"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

This is a multi-part message in MIME format.
--------------E7D7723C4105C974F53995DE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


*Georgi Nikolov*
System Administrator
www.icdsoft.com <http://www.icdsoft.com>

On 07/26/2018 11:48 AM, Vlastimil Babka wrote:
> On 07/26/2018 10:31 AM, Vlastimil Babka wrote:
>> On 07/26/2018 10:03 AM, Michal Hocko wrote:
>>> On Thu 26-07-18 09:50:45, Vlastimil Babka wrote:
>>>> On 07/26/2018 09:42 AM, Michal Hocko wrote:
>>>>> On Thu 26-07-18 09:34:58, Vlastimil Babka wrote:
>>>>>> On 07/26/2018 09:26 AM, Michal Hocko wrote:
>>>>>>> On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
>>>>>>>> On 07/25/2018 09:52 PM, Andrew Morton wrote:
>>>>>>>>
>>>>>>>> This is likely the kvmalloc() in xt_alloc_table_info(). Between =
4.13 and
>>>>>>>> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 05372=
50fdc6c
>>>>>>>> ("netfilter: x_tables: make allocation less aggressive") was bac=
kported
>>>>>>>> to 4.14. Removing __GFP_NORETRY might help here, but bring back =
other
>>>>>>>> issues. Less than 4MB is not that much though, maybe find some "=
sane"
>>>>>>>> limit and use __GFP_NORETRY only above that?
>>>>>>> I have seen the same report via http://lkml.kernel.org/r/df6f501c=
-8546-1f55-40b1-7e3a8f54d872@icdsoft.com
>>>>>>> and the reported confirmed that kvmalloc is not a real culprit
>>>>>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icd=
soft.com
>>>>>> Hmm but that was revert of eacd86ca3b03 ("net/netfilter/x_tables.c=
: use
>>>>>> kvmalloc() in xt_alloc_table_info()") which was the 4.13 commit th=
at
>>>>>> removed __GFP_NORETRY (there's no __GFP_NORETRY under net/netfilte=
r in
>>>>>> v4.14). I assume it was reverted on top of vanilla v4.14 as there =
would
>>>>>> be conflict on the stable with 0537250fdc6c backport. So what shou=
ld be
>>>>>> tested to be sure is either vanilla v4.14 without stable backports=
, or
>>>>>> latest v4.14.y with revert of 0537250fdc6c.
>>>>> But 0537250fdc6c simply restored the previous NORETRY behavior from=

>>>>> before eacd86ca3b03. So whatever causes these issues doesn't seem t=
o be
>>>>> directly related to the kvmalloc change. Or do I miss what you are
>>>>> saying?
>>>> I'm saying that although it's not a regression, as you say (the
>>>> vmalloc() there was only for a few kernel versions called without
>>>> __GFP_NORETRY), it's still possible that removing __GFP_NORETRY will=
 fix
>>>> the issue and thus we will rule out other possibilities.
>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft=
=2Ecom
>>> claims that reverting eacd86ca3b03 didn't really help.
> Ah, I see, that mail thread references a different kernel bugzilla
> #200639 which doesn't mention 4.14, but outright blames commit
> eacd86ca3b03. Yet the alloc fail message contains __GFP_NORETRY, so I
> still suspect the kernel also had 0537250fdc6c backport. Georgi can you=

> please clarify which exact kernel version had the alloc failures, and
> how exactly you tested the revert (which version was the baseline for
> revert). Thanks.
>
>> Of course not. eacd86ca3b03 *removed* __GFP_NORETRY, so the revert
>> reintroduced it. I tried to explain it in the quoted part above starti=
ng
>> with "Hmm but that was revert of eacd86ca3b03 ...". What I'm saying is=

>> that eacd86ca3b03 might have actually *fixed* (or rather prevented) th=
is
>> alloc failure, if there was not 0537250fdc6c and its 4.14 stable
>> backport (the kernel bugzilla report says 4.14, I'm assuming new enoug=
h
>> stable to contain 0537250fdc6c as the failure message contains
>> __GFP_NORETRY).
>>
>> The mail you reference also says "seems that old version is masking
>> errors", which confirms that we are indeed looking at the right
>> vmalloc(), because eacd86ca3b03 also removed __GFP_NOWARN there (and
>> thus the revert reintroduced it).
>>
>>

Hello,
Kernel that has allocation failures is 4.14.50.
Here is the patch applied to this version which masks errors:

--- net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-06-18 14:18:21.138347=
416 +0300
+++ net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-07-26 11:58:01.721932=
962 +0300
@@ -1059,9 +1059,19 @@
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* than shoot all processes down before rea=
lizing there is nothing
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* more to reclaim.
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0*/
-=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
+/*=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
=C2=A0=C2=A0=C2=A0=C2=A0 if (!info)
=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
+*/
+
+=C2=A0=C2=A0=C2=A0 if (sz <=3D (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D kmalloc(sz, GFP_KERNEL | =
__GFP_NOWARN | __GFP_NORETRY);
+=C2=A0=C2=A0=C2=A0 if (!info) {
+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D __vmalloc(sz, GFP_KERNEL =
| __GFP_NOWARN | __GFP_NORETRY,
+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0PAGE_KERNEL);
+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (!info)
+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
+=C2=A0=C2=A0=C2=A0 }
=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0 memset(info, 0, sizeof(*info));
=C2=A0=C2=A0=C2=A0=C2=A0 info->size =3D size;


I will try to reproduce it with only

info =3D kvmalloc(sz, GFP_KERNEL);

Regards,

--
Georgi Nikolov


--------------E7D7723C4105C974F53995DE
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <p><br>
    </p>
    <div class="moz-signature"><b>Georgi Nikolov</b><br>
      <font color="#7B858F">
        System Administrator<br>
        <a href="http://www.icdsoft.com">www.icdsoft.com</a><br>
      </font><br>
    </div>
    <div class="moz-cite-prefix">On 07/26/2018 11:48 AM, Vlastimil Babka
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz">
      <pre wrap="">On 07/26/2018 10:31 AM, Vlastimil Babka wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On 07/26/2018 10:03 AM, Michal Hocko wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">On Thu 26-07-18 09:50:45, Vlastimil Babka wrote:
</pre>
          <blockquote type="cite">
            <pre wrap="">On 07/26/2018 09:42 AM, Michal Hocko wrote:
</pre>
            <blockquote type="cite">
              <pre wrap="">On Thu 26-07-18 09:34:58, Vlastimil Babka wrote:
</pre>
              <blockquote type="cite">
                <pre wrap="">On 07/26/2018 09:26 AM, Michal Hocko wrote:
</pre>
                <blockquote type="cite">
                  <pre wrap="">On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
</pre>
                  <blockquote type="cite">
                    <pre wrap="">On 07/25/2018 09:52 PM, Andrew Morton wrote:

This is likely the kvmalloc() in xt_alloc_table_info(). Between 4.13 and
4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537250fdc6c
("netfilter: x_tables: make allocation less aggressive") was backported
to 4.14. Removing __GFP_NORETRY might help here, but bring back other
issues. Less than 4MB is not that much though, maybe find some "sane"
limit and use __GFP_NORETRY only above that?
</pre>
                  </blockquote>
                  <pre wrap="">
I have seen the same report via <a class="moz-txt-link-freetext" href="http://lkml.kernel.org/r/df6f501c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com">http://lkml.kernel.org/r/df6f501c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com</a>
and the reported confirmed that kvmalloc is not a real culprit
<a class="moz-txt-link-freetext" href="http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com">http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com</a>
</pre>
                </blockquote>
                <pre wrap="">
Hmm but that was revert of eacd86ca3b03 ("net/netfilter/x_tables.c: use
kvmalloc() in xt_alloc_table_info()") which was the 4.13 commit that
removed __GFP_NORETRY (there's no __GFP_NORETRY under net/netfilter in
v4.14). I assume it was reverted on top of vanilla v4.14 as there would
be conflict on the stable with 0537250fdc6c backport. So what should be
tested to be sure is either vanilla v4.14 without stable backports, or
latest v4.14.y with revert of 0537250fdc6c.
</pre>
              </blockquote>
              <pre wrap="">
But 0537250fdc6c simply restored the previous NORETRY behavior from
before eacd86ca3b03. So whatever causes these issues doesn't seem to be
directly related to the kvmalloc change. Or do I miss what you are
saying?
</pre>
            </blockquote>
            <pre wrap="">
I'm saying that although it's not a regression, as you say (the
vmalloc() there was only for a few kernel versions called without
__GFP_NORETRY), it's still possible that removing __GFP_NORETRY will fix
the issue and thus we will rule out other possibilities.
</pre>
          </blockquote>
          <pre wrap="">
<a class="moz-txt-link-freetext" href="http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com">http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com</a>
claims that reverting eacd86ca3b03 didn't really help.
</pre>
        </blockquote>
      </blockquote>
      <pre wrap="">
Ah, I see, that mail thread references a different kernel bugzilla
#200639 which doesn't mention 4.14, but outright blames commit
eacd86ca3b03. Yet the alloc fail message contains __GFP_NORETRY, so I
still suspect the kernel also had 0537250fdc6c backport. Georgi can you
please clarify which exact kernel version had the alloc failures, and
how exactly you tested the revert (which version was the baseline for
revert). Thanks.

</pre>
      <blockquote type="cite">
        <pre wrap="">Of course not. eacd86ca3b03 *removed* __GFP_NORETRY, so the revert
reintroduced it. I tried to explain it in the quoted part above starting
with "Hmm but that was revert of eacd86ca3b03 ...". What I'm saying is
that eacd86ca3b03 might have actually *fixed* (or rather prevented) this
alloc failure, if there was not 0537250fdc6c and its 4.14 stable
backport (the kernel bugzilla report says 4.14, I'm assuming new enough
stable to contain 0537250fdc6c as the failure message contains
__GFP_NORETRY).

The mail you reference also says "seems that old version is masking
errors", which confirms that we are indeed looking at the right
vmalloc(), because eacd86ca3b03 also removed __GFP_NOWARN there (and
thus the revert reintroduced it).


</pre>
      </blockquote>
      <pre wrap="">
</pre>
    </blockquote>
    <br>
    Hello,<br>
    Kernel that has allocation failures is 4.14.50.<br>
    Here is the patch applied to this version which masks errors:<br>
    <br>
    --- net/netfilter/x_tables.cA A A  2018-06-18 14:18:21.138347416 +0300<br>
    +++ net/netfilter/x_tables.cA A A  2018-07-26 11:58:01.721932962 +0300<br>
    @@ -1059,9 +1059,19 @@<br>
    A A A A  A * than shoot all processes down before realizing there is
    nothing<br>
    A A A A  A * more to reclaim.<br>
    A A A A  A */<br>
    -A A A  info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);<br>
    +/*A A A  info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);<br>
    A A A A  if (!info)<br>
    A A A A  A A A  return NULL;<br>
    +*/<br>
    +<br>
    +A A A  if (sz &lt;= (PAGE_SIZE &lt;&lt; PAGE_ALLOC_COSTLY_ORDER))<br>
    +A A A  A A A  info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
    __GFP_NORETRY);<br>
    +A A A  if (!info) {<br>
    +A A A  A A A  info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
    __GFP_NORETRY,<br>
    +A A A  A A A  A PAGE_KERNEL);<br>
    +A A A  A A A  if (!info)<br>
    +A A A  A A A  return NULL;<br>
    +A A A  }<br>
    A <br>
    A A A A  memset(info, 0, sizeof(*info));<br>
    A A A A  info-&gt;size = size;<br>
    <br>
    <br>
    I will try to reproduce it with only<br>
    <br>
    info = kvmalloc(sz, GFP_KERNEL);<br>
    <br>
    Regards,<br>
    <br>
    --<br>
    Georgi Nikolov<br>
    <br>
  </body>
</html>

--------------E7D7723C4105C974F53995DE--
