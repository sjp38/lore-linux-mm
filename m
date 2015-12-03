Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2D76B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 14:06:17 -0500 (EST)
Received: by ioc74 with SMTP id 74so91344465ioc.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:06:17 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0055.hostedemail.com. [216.40.44.55])
        by mx.google.com with ESMTPS id l2si403807igv.8.2015.12.03.11.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 11:06:16 -0800 (PST)
Date: Thu, 3 Dec 2015 14:06:14 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V2 2/7] mm/gup: add gup trace points
Message-ID: <20151203140614.75f49aad@gandalf.local.home>
In-Reply-To: <56608BA2.2050300@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
	<1449096813-22436-3-git-send-email-yang.shi@linaro.org>
	<565F8092.7000001@intel.com>
	<20151202231348.7058d6e2@grimm.local.home>
	<56608BA2.2050300@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Thu, 03 Dec 2015 10:36:18 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> > called directly that calls these functions internally and the tracepoint
> > can trap the return value.  
> 
> This will incur more changes in other subsystems (futex, kvm, etc), I'm 
> not sure if it is worth making such changes to get return value.

No, it wouldn't require any changes outside of this.

-long __get_user_pages(..)
+static long __get_user_pages_internal(..)
{
  [..]
}
+
+long __get_user_pages(..)
+{
+	long ret;
+	ret = __get_user_pages_internal(..);
+	trace_get_user_pages(.., ret)
+}

> 
> > I can probably make function_graph tracer give return values, although
> > it will give a return value for void functions as well. And it may give
> > long long returns for int returns that may have bogus data in the
> > higher bits.  
> 
> If the return value requirement is not limited to gup, the approach 
> sounds more reasonable.
>

Others have asked about it. Maybe I should do it.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
