Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0183280278
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 20:16:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o9so3113779pgv.3
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 17:16:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d1si4248606pgo.568.2018.01.05.17.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Jan 2018 17:16:55 -0800 (PST)
Date: Fri, 5 Jan 2018 17:16:50 -0800
From: Darren Hart <dvhart@infradead.org>
Subject: Re: [PATCH] ACPI / WMI: Call acpi_wmi_init() later
Message-ID: <20180106011650.GA5260@fury>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
 <2601877.IhOx20xkUK@aspire.rjw.lan>
 <CAJZ5v0jxVUxFetwPaj76FoeQjHtSSwO+4jiEqadA1WXZ_YNNoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jxVUxFetwPaj76FoeQjHtSSwO+4jiEqadA1WXZ_YNNoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Jonathan McDowell <noodles@earth.li>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Platform Driver <platform-driver-x86@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>

On Sat, Jan 06, 2018 at 12:30:23AM +0100, Rafael J. Wysocki wrote:
> On Wed, Jan 3, 2018 at 12:49 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> >
> > Calling acpi_wmi_init() at the subsys_initcall() level causes ordering
> > issues to appear on some systems and they are difficult to reproduce,
> > because there is no guaranteed ordering between subsys_initcall()
> > calls, so they may occur in different orders on different systems.
> >
> > In particular, commit 86d9f48534e8 (mm/slab: fix kmemcg cache
> > creation delayed issue) exposed one of these issues where genl_init()
> > and acpi_wmi_init() are both called at the same initcall level, but
> > the former must run before the latter so as to avoid a NULL pointer
> > dereference.
> >
> > For this reason, move the acpi_wmi_init() invocation to the
> > initcall_sync level which should still be early enough for things
> > to work correctly in the WMI land.
> >
> > Link: https://marc.info/?t=151274596700002&r=1&w=2
> > Reported-by: Jonathan McDowell <noodles@earth.li>
> > Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Tested-by: Jonathan McDowell <noodles@earth.li>
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Guys, this fixes a crash on boot.
> 
> If there are no concerns/objections I will just take it through the ACPI tree.

Queued up and running through tests now. I'll have it in for-next as soon as
those complete assuming to issues.

-- 
Darren Hart
VMware Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
