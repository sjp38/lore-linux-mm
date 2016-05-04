Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9456B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:42:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so126782307pfb.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:42:26 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 192si6270407pfz.229.2016.05.04.12.42.25
        for <linux-mm@kvack.org>;
        Wed, 04 May 2016 12:42:25 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Wed, 4 May 2016 19:41:59 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
In-Reply-To: <20160502130006.GD25265@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Thu 02-05-16 03:00:00, Michal Hocko wrote:
> So I have given this a try (not tested yet) and it doesn't look terribly
> complicated. It is hijacking vmstat for a purpose it wasn't intended for
> originally but creating a dedicated kenrnel threads/WQ sounds like an
> overkill to me. Does this helps or do we have to be more aggressive and
> wake up shepherd from the allocator slow path. Could you give it a try
> please?

It seems to work fine, but it takes quite random time to drain lists, somet=
imes
a couple of seconds sometimes over two minutes. It is acceptable I believe.

I have an app which allocates almost all of the memory from numa node and
with just second patch and 100 consecutive executions 30-50% got killed.
After applying also your first patch I haven't seen any oom kill activity -=
 great.

I was wondering how many lru_add_drain()'s are called and after boot when
machine was idle it was a bit over 5k calls during first 400s, and with som=
e=20
activity it went up to 15k calls during 700s (including 5k from previous=20
experiment) which sounds fair to me given big cpu count.

Do you see any advantages of dropping THP from pagevecs over this solution?

Thanks,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
