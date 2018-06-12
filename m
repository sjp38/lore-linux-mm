Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A55186B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 12:24:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e2-v6so7958761pgq.4
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:24:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s204-v6si406015pgs.280.2018.06.12.09.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 09:24:38 -0700 (PDT)
Message-ID: <1528820489.9324.14.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 12 Jun 2018 09:21:29 -0700
In-Reply-To: <CALCETrXK6hypCb5sXwxWRKr=J6_7XtS6s5GB1WPBiqi79q8-8g@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
	 <1528815820.8271.16.camel@2b52.sc.intel.com>
	 <CALCETrXK6hypCb5sXwxWRKr=J6_7XtS6s5GB1WPBiqi79q8-8g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: bsingharora@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Tue, 2018-06-12 at 09:00 -0700, Andy Lutomirski wrote:
> On Tue, Jun 12, 2018 at 8:06 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> > >
> > > On 08/06/18 00:37, Yu-cheng Yu wrote:
> > > > This series introduces CET - Shadow stack
> > > >
> > > > At the high level, shadow stack is:
> > > >
> > > >     Allocated from a task's address space with vm_flags VM_SHSTK;
> > > >     Its PTEs must be read-only and dirty;
> > > >     Fixed sized, but the default size can be changed by sys admin.
> > > >
> > > > For a forked child, the shadow stack is duplicated when the next
> > > > shadow stack access takes place.
> > > >
> > > > For a pthread child, a new shadow stack is allocated.
> > > >
> > > > The signal handler uses the same shadow stack as the main program.
> > > >
> > >
> > > Even with sigaltstack()?
> > >
> > >
> > > Balbir Singh.
> >
> > Yes.
> >
> 
> I think we're going to need some provision to add an alternate signal
> stack to handle the case where the shadow stack overflows.

The shadow stack stores only return addresses; its consumption will not
exceed a percentage of (program stack size + sigaltstack size) before
those overflow.  When that happens, there is usually very little we can
do.  So we set a default shadow stack size that supports certain nested
calls and allow sys admin to adjust it.
