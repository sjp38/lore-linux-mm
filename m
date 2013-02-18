Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5753C6B0005
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 01:15:18 -0500 (EST)
Message-ID: <5121C699.2050408@cn.fujitsu.com>
Date: Mon, 18 Feb 2013 14:13:45 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] net: fix functions and variables related to netns_ipvs->sysctl_sync_qlen_max
References: <51131B88.6040809@cn.fujitsu.com> <51132A56.60906@cn.fujitsu.com> <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg> <20130214142159.d0516a5f.akpm@linux-foundation.org> <alpine.LFD.2.00.1302152304010.1746@ja.ssi.bg>
In-Reply-To: <alpine.LFD.2.00.1302152304010.1746@ja.ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8816=E6=97=A5 05:39, Julian Anastasov =E5=
=86=99=E9=81=93:
>=20
> 	Hello,
>=20
> On Thu, 14 Feb 2013, Andrew Morton wrote:
>=20
>> On Thu, 7 Feb 2013 10:40:26 +0200 (EET)
>> Julian Anastasov <ja@ssi.bg> wrote:
>>
>>>> Another question about the sysctl=5Fsync=5Fqlen=5Fmax:
>>>> This variable is assigned as:
>>>>
>>>> ipvs->sysctl=5Fsync=5Fqlen=5Fmax =3D nr=5Ffree=5Fbuffer=5Fpages() / 32;
>>>>
>>>> The function nr=5Ffree=5Fbuffer=5Fpages actually means: counts of pages
>>>> which are beyond high watermark within ZONE=5FDMA and ZONE=5FNORMAL.
>>>>
>>>> is it ok to be called here? Some people misused this function because
>>>> the function name was misleading them. I am sorry I am totally not
>>>> familiar with the ipvs code, so I am just asking you about
>>>> this.
>>>
>>> 	Using nr=5Ffree=5Fbuffer=5Fpages should be fine here.
>>> We are using it as rough estimation for the number of sync
>>> buffers we can use in NORMAL zones. We are using dev->mtu
>>> for such buffers, so it can take a PAGE=5FSIZE for a buffer.
>>> We are not interested in HIGHMEM size. high watermarks
>>> should have negliable effect. I'm even not sure whether
>>> we need to clamp it for systems with TBs of memory.
>>
>> Using nr=5Ffree=5Fbuffer=5Fpages() is good-enough-for-now.  There are
>> questions around the name of this thing and its exact functionality and
>> whether callers are using it appropriately.  But if anything is changed
>> there, it will be as part of kernel-wide sweep.
>>
>> One thing to bear in mind is memory hot[un]plug.  Anything which was
>> sized using nr=5Ffree=5Fbuffer=5Fpages() (or similar) may become
>> inappropriately sized if memory is added or removed.  So any site which
>> uses nr=5Ffree=5Fbuffer=5Fpages() really should be associated with a hot=
plug
>> handler and a great pile of code to resize the structure at runtime.=20
>> It's pretty ugly stuff :(  I suspect it usually Just Doesn't Matter.
>=20
> 	I'll try to think on this hotplug problem
> and also on the si=5Fmeminfo usage in net/netfilter/ipvs/ip=5Fvs=5Fctl.c
> which is quite wrong for systems with HIGHMEM, may be
> we need there a free+reclaimable+file function for
> NORMAL zone.
>=20
>> Redarding this patch:
>> net-change-type-of-netns=5Fipvs-sysctl=5Fsync=5Fqlen=5Fmax.patch and
>> net-fix-functions-and-variables-related-to-netns=5Fipvs-sysctl=5Fsync=5F=
qlen=5Fmax.patch
>> are joined at the hip and should be redone as a single patch with a
>> suitable changelog, please.  And with a cc:netdev@vger.kernel.org.
>=20
> 	Agreed, Zhang Yanfei and Simon? I'm just not sure,
> may be this combined patch should hit only the
> ipvs->nf->net trees? Or may be net-next, if we don't have
> time for 3.8.
>=20

Should I resend the combined patch?
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
