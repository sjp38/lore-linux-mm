Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id B0F936B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 15:43:37 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so523825lab.9
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 12:43:36 -0700 (PDT)
Received: from mycroft.westnet.com (Mycroft.westnet.com. [216.187.52.7])
        by mx.google.com with ESMTPS id eo1si25191895lac.130.2014.07.03.12.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 12:43:35 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <21429.45664.255694.85431@quad.stoffel.home>
Date: Thu, 3 Jul 2014 15:43:28 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
In-Reply-To: <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
	<53B59CB5.9060004@linux.vnet.ibm.com>
	<CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
	<CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

>>>>> "Linus" == Linus Torvalds <torvalds@linux-foundation.org> writes:

Linus> On Thu, Jul 3, 2014 at 11:22 AM, Linus Torvalds
Linus> <torvalds@linux-foundation.org> wrote:
>> 
>> So the bugzilla entry worries me a bit - we definitely do not want to
>> regress in case somebody really relied on timing - but without more
>> specific information I still think the real bug is just in the
>> man-page.

Linus> Side note: the 2MB limit may be too small. 2M is peanuts on modern
Linus> machines, even for fairly slow IO, and there are lots of files (like
Linus> glibc etc) that people might want to read-ahead during boot. We
Linus> already do bigger read-ahead if people just do "read()" system calls.
Linus> So I could certainly imagine that we should increase it.

Linus> I do *not* think we should bow down to insane man-pages that have
Linus> always been wrong, though, and I don't think we should increase it to
Linus> "let's just read-ahead a whole ISO image" kind of sizes..

This is one of those perenial questions of how to tune this.  I agree
we should increase the number, but shouldn't it be based on both the
amount of memory in the machine, number of devices (or is it all just
one big pool?) and the speed of the actual device doing readahead?
Doesn't make sense to do 32mb of readahead on a USB 1.1 thumb drive or
even a CDROM.  But maybe it does for USB3 thumb drives?  

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
