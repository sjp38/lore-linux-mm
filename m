Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
In-Reply-To: <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Jan 2019 22:27:58 -0800
Message-ID: <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Jane Chu <jane.chu@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Takashi Iwai <tiwai@suse.de>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, "Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 10:13 PM Jane Chu <jane.chu@oracle.com> wrote:
>
> Hi, Dave,
>
> While chatting with my colleague Erwin about the patchset, it occurred
> that we're not clear about the error handling part. Specifically,
>
> 1. If an uncorrectable error is detected during a 'load' in the hot
> plugged pmem region, how will the error be handled?  will it be
> handled like PMEM or DRAM?

DRAM.

> 2. If a poison is set, and is persistent, which entity should clear
> the poison, and badblock(if applicable)? If it's user's responsibility,
> does ndctl support the clearing in this mode?

With persistent memory advertised via a static logical-to-physical
storage/dax device mapping, once an error develops it destroys a
physical *and* logical part of a device address space. That loss of
logical address space makes error clearing a necessity. However, with
the DRAM / "System RAM" error handling model, the OS can just offline
the page and map a different one to repair the logical address space.
So, no, ndctl will not have explicit enabling to clear volatile
errors, the OS will just dynamically offline problematic pages.
