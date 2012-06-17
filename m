Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 62AFC6B0068
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 06:37:30 -0400 (EDT)
Received: by obbtb8 with SMTP id tb8so435813obb.14
        for <linux-mm@kvack.org>; Sun, 17 Jun 2012 03:37:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206161811020.797@chino.kir.corp.google.com>
References: <1338438844-5022-1-git-send-email-andi@firstfloor.org>
	<1339234803-21106-1-git-send-email-tdmackey@twitter.com>
	<alpine.DEB.2.00.1206091917580.7832@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1206161811020.797@chino.kir.corp.google.com>
Date: Sun, 17 Jun 2012 13:37:29 +0300
Message-ID: <CAOJsxLGhQSZjY8jcL7tB2-oicak-H68CW5S8OOMz8cEh=m5hjg@mail.gmail.com>
Subject: Re: [PATCH v5] slab/mempolicy: always use local policy from interrupt context
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: David Mackey <tdmackey@twitter.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, cl@linux.com

On Sun, Jun 17, 2012 at 4:11 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Sat, 9 Jun 2012, David Rientjes wrote:
>
>> On Sat, 9 Jun 2012, David Mackey wrote:
>>
>> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> > index f15c1b2..cb0b230 100644
>> > --- a/mm/mempolicy.c
>> > +++ b/mm/mempolicy.c
>> > @@ -1602,8 +1602,14 @@ static unsigned interleave_nodes(struct mempoli=
cy *policy)
>> > =A0 * task can change it's policy. =A0The system default policy requir=
es no
>> > =A0 * such protection.
>> > =A0 */
>> > -unsigned slab_node(struct mempolicy *policy)
>> > +unsigned slab_node(void)
>> > =A0{
>> > + =A0 struct mempolicy *policy;
>> > +
>> > + =A0 if (in_interrupt())
>> > + =A0 =A0 =A0 =A0 =A0 return numa_node_id();
>> > +
>> > + =A0 policy =3D current->mempolicy;
>> > =A0 =A0 if (!policy || policy->flags & MPOL_F_LOCAL)
>> > =A0 =A0 =A0 =A0 =A0 =A0 return numa_node_id();
>> >
>>
>> Should probably be numa_mem_id() in both these cases for
>> CONFIG_HAVE_MEMORYLESS_NODES, but it won't cause a problem in this form
>> either.
>>
>> Acked-by: David Rientjes <rientjes@google.com>
>>
>
> Still missing from linux-next, who's going to pick this up?

I'm going to pick it up. I've been postponing merging it until dust
has settled from Christoph's "common slab" patch series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
