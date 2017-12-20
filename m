Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37F276B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:24:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a74so17074553pfg.20
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:24:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v3si13624342plb.385.2017.12.20.13.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 13:24:10 -0800 (PST)
Date: Wed, 20 Dec 2017 14:24:08 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171220212408.GA8308@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
 <20171218203547.GA2366@linux.intel.com>
 <20171220181937.GB12236@bombadil.infradead.org>
 <2da89d31-27a3-34ab-2dbb-92403c8215ec@intel.com>
 <20171220211649.GA32200@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220211649.GA32200@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Dec 20, 2017 at 01:16:49PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 20, 2017 at 12:22:21PM -0800, Dave Hansen wrote:
> > On 12/20/2017 10:19 AM, Matthew Wilcox wrote:
> > > I don't know what the right interface is, but my laptop has a set of
> > > /sys/devices/system/memory/memoryN/ directories.  Perhaps this is the
> > > right place to expose write_bw (etc).
> > 
> > Those directories are already too redundant and wasteful.  I think we'd
> > really rather not add to them.  In addition, it's technically possible
> > to have a memory section span NUMA nodes and have different performance
> > properties, which make it impossible to represent there.
> > 
> > In any case, ACPI PXM's (Proximity Domains) are guaranteed to have
> > uniform performance properties in the HMAT, and we just so happen to
> > always create one NUMA node per PXM.  So, NUMA nodes really are a good fit.
> 
> I think you're missing my larger point which is that I don't think this
> should be exposed to userspace as an ACPI feature.  Because if you do,
> then it'll also be exposed to userspace as an openfirmware feature.
> And sooner or later a devicetree feature.  And then writing a portable
> program becomes an exercise in suffering.
> 
> So, what's the right place in sysfs that isn't tied to ACPI?  A new
> directory or set of directories under /sys/devices/system/memory/ ?

Oh, the current location isn't at all tied to acpi except that it happens to
be named 'hmat'.  When it was all named 'hmem' it was just:

/sys/devices/system/hmem

Which has no ACPI-isms at all.  I'm happy to move it under
/sys/devices/system/memory/hmat if that's helpful, but I think we still have
the issue that the data represented therein is still pulled right from the
HMAT, and I don't know how to abstract it into something more platform
agnostic until I know what data is provided by those other platforms.

For example, the HMAT provides latency information and bandwidth information
for both reads and writes.  Will the devicetree/openfirmware/etc version have
this same info, or will it be just different enough that it won't translate
into whatever I choose to stick in sysfs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
