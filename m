Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DA6D6B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 02:16:42 -0500 (EST)
Date: Tue, 3 Nov 2009 09:16:38 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
Message-ID: <20091103071638.GK27911@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-2-git-send-email-gleb@redhat.com>
 <4AEECE2E.2050609@redhat.com>
 <20091102161809.GG27911@redhat.com>
 <4AEFBC5E.7020300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AEFBC5E.7020300@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 03, 2009 at 07:15:10AM +0200, Avi Kivity wrote:
> On 11/02/2009 06:18 PM, Gleb Natapov wrote:
> >>>+#define KVM_PV_SHM_VERSION 1
> >>versions = bad, feature bits = good
> >>
> >I have both! Do you want me to drop version?
> 
> Yes.  Once a kernel is released you can't realistically change the version.
> 
Why not? If version doesn't match apf will not be used.

> >>Some documentation for this?
> >>
> >>Also, the name should reflect the pv pagefault use.  For other uses
> >>we can register other areas.
> >>
> >I wanted it to be generic, but I am fine with making it apf specific.
> >It will allow to make it smaller too.
> 
> Maybe we can squeeze it into the page-fault error code?
> 
apf has to pass two things into a guest kernel:
 - event type (page not present/wake up)
 - unique token
Error code has 32 bits and at least 1 of them should indicate that this
is apf another one should indicate event type so this leaves us 30 bits
for a token. 12 bits of a token is used to store vcpu id this leaves 18
bits for unique per vcpu id. Yes this may be enough. I don't think it is
realistic to have more then 200000 outstanding apfs per vcpu. Alternately
we can use CR2 to pass a token.
 
> >>would solve this.  I prefer using put_user() though than a permanent
> >>get_user_pages().
> >>
> >I want to prevent it from been swapped out.
> 
> Since you don't prevent the page fault handler or code from being
> swapped out, you don't get anything out of it.
> 
Performance. Currently it is accessed on each page fault and to access
it gup+kmap should be done each and every time.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
