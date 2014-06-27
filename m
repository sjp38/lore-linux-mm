Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5206C6B003B
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 13:34:51 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so4818853pbc.17
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:34:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nd4si14719362pbc.20.2014.06.27.10.34.49
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 10:34:50 -0700 (PDT)
Message-ID: <53ADAB39.6030403@intel.com>
Date: Fri, 27 Jun 2014 10:34:49 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu> <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com> <53A88DE4.8050107@intel.com> <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016AF41C@shsmsx102.ccr.corp.intel.com> <CALCETrX+iS5N8bCUm_O-1E4GPu4oG-SuFJoJjx_+S054K9-6pw@mail.gmail.com> <9E0BE1322F2F2246BD820DA9FC397ADE016B26AB@shsmsx102.ccr.corp.intel.com> <CALCETrWmmVC2qQtL0Js_Y7LvSPdTh5Hpk6c5ZG3Rt8uTJBWoHQ@mail.gmail.com> <CALCETrUD3L5Ta_v+NqgUrTk7Ok3zE=CRg0rqeKthOj2OORCLKQ@mail.gmail.com> <53AB42E1.4090102@intel.com> <CALCETrVTTh9yuXH0hfcOpytyBd25K6thPfqqUBQtnOqx90ZRqw@mail.gmail.com> <53ACA5B3.3010702@intel.com> <CALCETrVceOhRunCg1b9Q3VL10Kcb+uA-HFUURnq5f2S63_jACg@mail.gmail.com> <53ACB8A7.9050002@intel.com> <CALCETrVR9QB3QvA2x_JjAXCFoqMw4B+byFTPDC3gQMUC1C-2NA@mail.gmail.com>
In-Reply-To: <CALCETrVR9QB3QvA2x_JjAXCFoqMw4B+byFTPDC3gQMUC1C-2NA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 06/26/2014 05:26 PM, Andy Lutomirski wrote:
> On Thu, Jun 26, 2014 at 5:19 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>> On 06/26/2014 04:15 PM, Andy Lutomirski wrote:
>>> Also, egads: what happens when a bound table entry is associated with
>>> a MAP_SHARED page?
>>
>> Bounds table entries are for pointers.  Do we keep pointers inside of
>> MAP_SHARED-mapped things? :)
> 
> Sure, if it's MAP_SHARED | MAP_ANONYMOUS.  For example:
> 
> struct thing {
>   struct thing *next;
> };
> 
> struct thing *storage = mmap(..., MAP_SHARED | MAP_ANONYMOUS, ...);
> storage[0].next = &storage[1];
> fork();
> 
> I'm not suggesting that this needs to *work* in the first incarnation of this :)

I'm not sure I'm seeing the issue.

I'm claiming that we need COW behavior for the bounds tables, at least
by default.  If userspace knows enough about the ways that it is using
the tables and knows how to share them, let it go to town.  The kernel
will permit this kind of usage model, but we simply won't be helping
with the management of the tables when userspace creates them.

You've demonstrated a case where userspace might theoretically might
want to share bounds tables (although I think it's pretty dangerous).
It's equally theoretically possible that userspace might *not* want to
share the tables for instance if one process narrowed the bounds and the
other did not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
