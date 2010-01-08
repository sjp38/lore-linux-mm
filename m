Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C9A156B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 19:55:46 -0500 (EST)
Message-ID: <4B46828C.5000703@cn.fujitsu.com>
Date: Fri, 08 Jan 2010 08:55:40 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
 	notifications
References: <cover.1262186097.git.kirill@shutemov.name>	 <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>	 <6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com> <cc557aab1001070436w446ef85n55dd2af5e733f55e@mail.gmail.com>
In-Reply-To: <cc557aab1001070436w446ef85n55dd2af5e733f55e@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Paul Menage <menage@google.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kirill A. Shutemov wrote:
> On Thu, Jan 7, 2010 at 3:01 AM, Paul Menage <menage@google.com> wrote:
>> On Wed, Dec 30, 2009 at 7:57 AM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>>> +
>>> +       if (!IS_ERR(efile))
>>> +               fput(efile);
>> While this is OK currently, it's a bit fragile. efile starts as NULL,
>> and IS_ERR(NULL) is false. So if we jump to fail: before trying to do
>> the eventfd_fget() then we'll try to fput(NULL), which will oops. This
>> works because we don't currently jump to fail: until after
>> eventfd_fget(), but someone could add an extra setup step between the
>> kzalloc() and the eventfd_fget() which could fail.
> 
> So we need to use IS_ERR_OR_NULL here instread of IS_ERR, don't we?
> 

Use multi labels is much better:

label4::
	fput(cfile);
label3:
	eventfd_ctx_put(event->eventfd);
label2:
	fput(efile);
label1:
	kfree(event);

compared to:

+fail:
+	if (!IS_ERR(cfile))
+		fput(cfile);
+
+	if (event && event->eventfd && !IS_ERR(event->eventfd))
+		eventfd_ctx_put(event->eventfd);
+
+	if (!IS_ERR(efile))
+		fput(efile);
+
+	kfree(event);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
