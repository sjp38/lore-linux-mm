Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 348636B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:43:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z11-v6so3936598pgu.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:43:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 7-v6si56072500pll.212.2018.06.07.13.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:43:28 -0700 (PDT)
Message-ID: <1528404016.5646.0.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 05/10] x86/cet: ELF header parsing of Control Flow
 Enforcement
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 13:40:16 -0700
In-Reply-To: <CALCETrVyGdWnU1B5vZK4QP2TGVjTCg5wsPX8iAQRGzpcGNGr5g@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-6-yu-cheng.yu@intel.com>
	 <CALCETrVyGdWnU1B5vZK4QP2TGVjTCg5wsPX8iAQRGzpcGNGr5g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 11:38 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > Look in .note.gnu.property of an ELF file and check if shadow stack needs
> > to be enabled for the task.
> 
> Nice!  But please structure it so it's one function that parses out
> all the ELF notes and some other code (a table or a switch statement)
> that handles them.  We will probably want to add more kernel-parsed
> ELF notes some day, so let's structure the code to make it easier.
> 
> > +static int find_cet(u8 *buf, u32 size, u32 align, int *shstk, int *ibt)
> > +{
> > +       unsigned long start = (unsigned long)buf;
> > +       struct elf_note *note = (struct elf_note *)buf;
> > +
> > +       *shstk = 0;
> > +       *ibt = 0;
> > +
> > +       /*
> > +        * Go through the x86_note_gnu_property array pointed by
> > +        * buf and look for shadow stack and indirect branch
> > +        * tracking features.
> > +        * The GNU_PROPERTY_X86_FEATURE_1_AND entry contains only
> > +        * one u32 as data.  Do not go beyond buf_size.
> > +        */
> > +
> > +       while ((unsigned long) (note + 1) - start < size) {
> > +               /* Find the NT_GNU_PROPERTY_TYPE_0 note. */
> > +               if (note->n_namesz == 4 &&
> > +                   note->n_type == NT_GNU_PROPERTY_TYPE_0 &&
> > +                   memcmp(note + 1, "GNU", 4) == 0) {
> > +                       u8 *ptr, *ptr_end;
> > +
> > +                       /* Check for invalid property. */
> > +                       if (note->n_descsz < 8 ||
> > +                          (note->n_descsz % align) != 0)
> > +                               return 0;
> > +
> > +                       /* Start and end of property array. */
> > +                       ptr = (u8 *)(note + 1) + 4;
> > +                       ptr_end = ptr + note->n_descsz;
> 
> Exploitable bug here?  You haven't checked that ptr is in bounds or
> that ptr + ptr_end is in bounds (or that ptr_end > ptr, for that
> matter).
> 
> > +
> > +                       while (1) {
> > +                               u32 type = *(u32 *)ptr;
> > +                               u32 datasz = *(u32 *)(ptr + 4);
> > +
> > +                               ptr += 8;
> > +                               if ((ptr + datasz) > ptr_end)
> > +                                       break;
> > +
> > +                               if (type == GNU_PROPERTY_X86_FEATURE_1_AND &&
> > +                                   datasz == 4) {
> > +                                       u32 p = *(u32 *)ptr;
> > +
> > +                                       if (p & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
> > +                                               *shstk = 1;
> > +                                       if (p & GNU_PROPERTY_X86_FEATURE_1_IBT)
> > +                                               *ibt = 1;
> > +                                       return 1;
> > +                               }
> > +                       }
> > +               }
> > +
> > +               /*
> > +                * Note sections like .note.ABI-tag and .note.gnu.build-id
> > +                * are aligned to 4 bytes in 64-bit ELF objects.
> > +                */
> > +               note = (void *)note + ELF_NOTE_NEXT_OFFSET(note, align);
> 
> A malicious value here will probably just break out of the while
> statement, but it's still scary.
> 
> > +       }
> > +
> > +       return 0;
> > +}
> > +
> > +static int check_pt_note_segment(struct file *file,
> > +                                unsigned long note_size, loff_t *pos,
> > +                                u32 align, int *shstk, int *ibt)
> > +{
> > +       int retval;
> > +       char *note_buf;
> > +
> > +       /*
> > +        * Try to read in the whole PT_NOTE segment.
> > +        */
> > +       note_buf = kmalloc(note_size, GFP_KERNEL);
> 
> kmalloc() with fully user-controlled, unchecked size is not a good idea.

I will fix these problems.  Thanks!
