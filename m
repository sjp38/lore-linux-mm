Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id BB4AF6B00A0
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:09:30 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id q59so1000619wes.6
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:09:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf8si18759344wjc.150.2014.02.25.15.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 15:09:29 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <530CD443.7010400@intel.com>
Date: Wed, 26 Feb 2014 07:09:10 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4B3C0B08-45E1-48EF-8030-A3365F0E7CF6@suse.de>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <530CD443.7010400@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>



> Am 26.02.2014 um 01:34 schrieb Dave Hansen <dave.hansen@intel.com>:
>=20
>> On 02/24/2014 03:28 PM, Alexander Graf wrote:
>> Configuration of tunables and Linux virtual memory settings has tradition=
ally
>> happened via sysctl. Thanks to that there are well established ways to ma=
ke
>> sysctl configuration bits persistent (sysctl.conf).
>>=20
>> KSM introduced a sysfs based configuration path which is not covered by u=
ser
>> space persistent configuration frameworks.
>>=20
>> In order to make life easy for sysadmins, this patch adds all access to a=
ll
>> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as we=
ll,
>> giving us a streamlined way to make KSM configuration persistent.
>=20
> Doesn't this essentially mean "don't use sysfs for configuration"?
> Seems like at least /sys/kernel/mm/transparent_hugepage would need the
> same treatment.
>=20
> Couldn't we also (maybe in parallel) just teach the sysctl userspace
> about sysfs?  This way we don't have to do parallel sysctls and sysfs
> for *EVERYTHING* in the kernel:
>=20
>    sysfs.kernel.mm.transparent_hugepage.enabled=3Denabled

It's pretty hard to filter this. We definitely do not want to expose all of s=
ysfs through /proc/sys. But how do we know which files are actual configurat=
ion and which ones are dynamic system introspection data?

We could add a filter, but then we can just as well stick with the manual ap=
proach I followed here :).

>=20
> Or do we just say "sysctls are the way to go for anything that might
> need to be persistent, don't use sysfs"?

IMHO there are 2 paths we can take:

1) Admit that using sysfs for configuration is a bad idea, use sysctl instea=
d

2) Invent a streamlined way to set sysfs configuration variables similar to h=
ow we can set sysctl values

I'm not really sure which path is nicer. But the sitaution today is not exac=
tly satisfactory. The most common solution to ksm configuration is an init  o=
r systemd script that sets the respective config variables.


Alex=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
