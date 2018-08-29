Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1586B4C61
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:22:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u195-v6so4665735qka.14
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:22:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6-v6sor2123707qvm.125.2018.08.29.08.22.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 08:22:38 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise ||
 always
Date: Wed, 29 Aug 2018 11:22:35 -0400
Message-ID: <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
In-Reply-To: <20180829143545.GY10223@dhcp22.suse.cz>
References: <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz> <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz> <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_0574C3B0-C2B4-4D20-9A7E-3B0CF37073C6_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_0574C3B0-C2B4-4D20-9A7E-3B0CF37073C6_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 29 Aug 2018, at 10:35, Michal Hocko wrote:

> On Wed 29-08-18 16:28:16, Michal Hocko wrote:
>> On Wed 29-08-18 09:28:21, Zi Yan wrote:
>> [...]
>>> This patch triggers WARN_ON_ONCE() in policy_node() when MPOL_BIND is=
 used and THP is on.
>>> Should this WARN_ON_ONCE be removed?
>>>
>>>
>>> /*
>>> * __GFP_THISNODE shouldn't even be used with the bind policy
>>> * because we might easily break the expectation to stay on the
>>> * requested node and not break the policy.
>>> */
>>> WARN_ON_ONCE(policy->mode =3D=3D MPOL_BIND && (gfp & __GFP_THISNODE))=
;
>>
>> This is really interesting. It seems to be me who added this warning b=
ut
>> I cannot simply make any sense of it. Let me try to dig some more.
>
> OK, I get it now. The warning seems to be incomplete. It is right to
> complain when __GFP_THISNODE disagrees with MPOL_BIND policy but that i=
s
> not what we check here. Does this heal the warning?
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da858f794eb6..7bb9354b1e4c 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1728,7 +1728,10 @@ static int policy_node(gfp_t gfp, struct mempoli=
cy *policy,
>  		 * because we might easily break the expectation to stay on the
>  		 * requested node and not break the policy.
>  		 */
> -		WARN_ON_ONCE(policy->mode =3D=3D MPOL_BIND && (gfp & __GFP_THISNODE)=
);
> +		if (policy->mode =3D=3D MPOL_BIND && (gfp & __GFP_THISNODE)) {
> +			nodemask_t *nmask =3D policy_nodemask(gfp, policy);
> +			WARN_ON_ONCE(!node_isset(nd, *nmask));
> +		}
>  	}
>
>  	return nd;

Unfortunately no. I simply ran =E2=80=9Cmemhog -r3 1g membind 1=E2=80=9D =
to test and the warning still showed up.

The reason is that nd is just a hint about which node to prefer for alloc=
ation and
can be ignored if it does not conform to mempolicy.
Taking my test as an example, if an application is only memory bound to n=
ode 1 but can run on any CPU
nodes and it launches on node 0, alloc_pages_vma() will see 0 as its node=
 parameter
and passes 0 to policy_node()=E2=80=99s nd parameter. This should be OK, =
but your patches
would give a warning, because nd=3D0 is not set in nmask=3D1.

Now I get your comment =E2=80=9C__GFP_THISNODE shouldn't even be used wit=
h the bind policy=E2=80=9D,
since they are indeed incompatible. __GFP_THISNODE wants to use the node,=

which can be ignored by MPOL_BIND policy.

IMHO, we could get rid of __GFP_THISNODE when MPOL_BIND is set, like

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0d2be5786b0c..a0fcb998d277 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1722,14 +1722,6 @@ static int policy_node(gfp_t gfp, struct mempolicy=
 *policy,
 {
        if (policy->mode =3D=3D MPOL_PREFERRED && !(policy->flags & MPOL_=
F_LOCAL))
                nd =3D policy->v.preferred_node;
-       else {
-               /*
-                * __GFP_THISNODE shouldn't even be used with the bind po=
licy
-                * because we might easily break the expectation to stay =
on the
-                * requested node and not break the policy.
-                */
-               WARN_ON_ONCE(policy->mode =3D=3D MPOL_BIND && (gfp & __GF=
P_THISNODE));
-       }

        return nd;
 }
@@ -2026,6 +2018,13 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_ar=
ea_struct *vma,
                goto out;
        }

+       /*
+        * __GFP_THISNODE shouldn't even be used with the bind policy
+        * because we might easily break the expectation to stay on the
+        * requested node and not break the policy.
+        */
+       if (pol->mode =3D=3D MPOL_BIND)
+               gfp &=3D ~__GFP_THISNODE;

        nmask =3D policy_nodemask(gfp, pol);
        preferred_nid =3D policy_node(gfp, pol, node);

What do you think?

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_0574C3B0-C2B4-4D20-9A7E-3B0CF37073C6_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluGujsWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzHgRB/98tzWMhNloyZHsUZQQfDkK5oRn
tK+xRrsP8ihP0OBis1Evmn8rbrdDjRGlrOJTA2H3a0YGANSMow22bB0YzFkPg9PY
WefUWn90njnpDlhjDLGPW4F9p7R3V5J9aVOknbSsJ+ar/m50Aq1lXZctHJI8bLw1
oyUUmeTuLs16FZof6v+UmaCLF8FItIEylXNIAiO4ouzpKtA5jNBRswloFgVRWIg4
+bQaC/gJnli9QpJDvJvLkFeU3e9dpXbEkbGKAvgXRr63KbT5j65jBZfz1PT64mcm
WmaVG76qFPSLs3Op9YbChQ2ixGXuX/CWPRNNBD9Yy1v3bhq79w+IXa6G1s6o
=2pUd
-----END PGP SIGNATURE-----

--=_MailMate_0574C3B0-C2B4-4D20-9A7E-3B0CF37073C6_=--
