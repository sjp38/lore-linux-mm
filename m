Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 356466B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 01:23:14 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hm6so168913wib.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 22:23:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <509AC164.1050403@linux.vnet.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
 <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com> <509985DE.8000508@linux.vnet.ibm.com>
 <509AC164.1050403@linux.vnet.ibm.com>
From: Ankita Garg <gargankita@gmail.com>
Date: Fri, 9 Nov 2012 00:22:52 -0600
Message-ID: <CAKD8UxccEqUJVFcod7KCJeyk+-g_Vdb_vg=YuWxs4dLEU=8CrA@mail.gmail.com>
Subject: Re: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
Content-Type: multipart/alternative; boundary=f46d04428af2782d7904ce09fce9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--f46d04428af2782d7904ce09fce9
Content-Type: text/plain; charset=ISO-8859-1

Hi Srivatsa,

I understand that you are maintaining the page blocks in region sorted
order. So that way, when the memory requests come in, you can hand out
memory from the regions in that order. However, do you take this scenario
into account - in some bucket of the buddy allocator, there might not be
any pages belonging to, lets say, region 0, while the next higher bucket
has them. So, instead of handing out memory from whichever region thats
present there, to probably go to the next bucket and split that region 0
pageblock there and allocate from it ? (Here, region 0 is just an example).
Been a while since I looked at kernel code, so I might be missing something!

Regards,
Ankita



On Wed, Nov 7, 2012 at 2:15 PM, Srivatsa S. Bhat <
srivatsa.bhat@linux.vnet.ibm.com> wrote:

> On 11/07/2012 03:19 AM, Dave Hansen wrote:
> > On 11/06/2012 11:53 AM, Srivatsa S. Bhat wrote:
> >> This is the main change - we keep the pageblocks in region-sorted order,
> >> where pageblocks belonging to region-0 come first, followed by those
> belonging
> >> to region-1 and so on. But the pageblocks within a given region need
> *not* be
> >> sorted, since we need them to be only region-sorted and not fully
> >> address-sorted.
> >>
> >> This sorting is performed when adding pages back to the freelists, thus
> >> avoiding any region-related overhead in the critical page allocation
> >> paths.
> >
> > It's probably _better_ to do it at free time than alloc, but it's still
> > pretty bad to be doing a linear walk over a potentially 256-entry array
> > holding the zone lock.  The overhead is going to show up somewhere.  How
> > does this do with a kernel compile?  Looks like exit() when a process
> > has a bunch of memory might get painful.
> >
>
> As I mentioned in the cover-letter, kernbench numbers haven't shown any
> observable performance degradation. On the contrary, (as unbelievable as it
> may sound), they actually indicate a slight performance *improvement* with
> my
> patchset! I'm trying to figure out what could be the reason behind that.
>
> Going forward, we could try to optimize the sorting logic in the free()
> part, but in any case, IMHO that's the right place to push the overhead to,
> since the performance of free() is not expected to be _that_ critical
> (unlike
> alloc()) for overall system performance.
>
> Regards,
> Srivatsa S. Bhat
>
>


-- 
Regards,
Ankita
Graduate Student
Department of Computer Science
University of Texas at Austin

--f46d04428af2782d7904ce09fce9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<span style=3D"font-family:arial,sans-serif;font-size:12.499999046325684px"=
>Hi Srivatsa,</span><div style=3D"font-family:arial,sans-serif;font-size:12=
.499999046325684px"><br></div><div style=3D"font-family:arial,sans-serif;fo=
nt-size:12.499999046325684px">

I understand that you are maintaining the page blocks in region sorted orde=
r. So that way, when the memory requests come in, you can hand out memory f=
rom the regions in that order. However, do you take this scenario into acco=
unt - in some bucket of the buddy allocator, there might not be any pages b=
elonging to, lets say, region 0, while the next higher bucket has them. So,=
 instead of handing out memory from whichever region thats present there, t=
o probably go to the next bucket and split that region 0 pageblock there an=
d allocate from it ? (Here, region 0 is just an example). Been a while sinc=
e I looked at kernel code, so I might be missing something!</div>

<div style=3D"font-family:arial,sans-serif;font-size:12.499999046325684px">=
<br></div><div style=3D"font-family:arial,sans-serif;font-size:12.499999046=
325684px">Regards,</div><div style=3D"font-family:arial,sans-serif;font-siz=
e:12.499999046325684px">

Ankita</div><div style=3D"font-family:arial,sans-serif;font-size:12.4999990=
46325684px"><br></div><div class=3D"gmail_extra"><br><br><div class=3D"gmai=
l_quote">On Wed, Nov 7, 2012 at 2:15 PM, Srivatsa S. Bhat <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:srivatsa.bhat@linux.vnet.ibm.com" target=3D"_blank">=
srivatsa.bhat@linux.vnet.ibm.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On 1=
1/07/2012 03:19 AM, Dave Hansen wrote:<br>
&gt; On 11/06/2012 11:53 AM, Srivatsa S. Bhat wrote:<br>
&gt;&gt; This is the main change - we keep the pageblocks in region-sorted =
order,<br>
&gt;&gt; where pageblocks belonging to region-0 come first, followed by tho=
se belonging<br>
&gt;&gt; to region-1 and so on. But the pageblocks within a given region ne=
ed *not* be<br>
&gt;&gt; sorted, since we need them to be only region-sorted and not fully<=
br>
&gt;&gt; address-sorted.<br>
&gt;&gt;<br>
&gt;&gt; This sorting is performed when adding pages back to the freelists,=
 thus<br>
&gt;&gt; avoiding any region-related overhead in the critical page allocati=
on<br>
&gt;&gt; paths.<br>
&gt;<br>
&gt; It&#39;s probably _better_ to do it at free time than alloc, but it&#3=
9;s still<br>
&gt; pretty bad to be doing a linear walk over a potentially 256-entry arra=
y<br>
&gt; holding the zone lock. =A0The overhead is going to show up somewhere. =
=A0How<br>
&gt; does this do with a kernel compile? =A0Looks like exit() when a proces=
s<br>
&gt; has a bunch of memory might get painful.<br>
&gt;<br>
<br>
</div></div>As I mentioned in the cover-letter, kernbench numbers haven&#39=
;t shown any<br>
observable performance degradation. On the contrary, (as unbelievable as it=
<br>
may sound), they actually indicate a slight performance *improvement* with =
my<br>
patchset! I&#39;m trying to figure out what could be the reason behind that=
.<br>
<br>
Going forward, we could try to optimize the sorting logic in the free()<br>
part, but in any case, IMHO that&#39;s the right place to push the overhead=
 to,<br>
since the performance of free() is not expected to be _that_ critical (unli=
ke<br>
alloc()) for overall system performance.<br>
<br>
Regards,<br>
Srivatsa S. Bhat<br>
<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>Regards,<br>=
Ankita<div>Graduate Student</div><div>Department of Computer Science</div><=
div>University of Texas at Austin<br><br></div><br>
</div>

--f46d04428af2782d7904ce09fce9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
