Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 0F45C6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:02:51 -0400 (EDT)
Received: by qafk30 with SMTP id k30so4616615qaf.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 17:02:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120904164636.158d8012.akpm@linux-foundation.org>
References: <1346801989-18274-1-git-send-email-walken@google.com>
	<20120904164636.158d8012.akpm@linux-foundation.org>
Date: Tue, 4 Sep 2012 17:02:49 -0700
Message-ID: <CANN689HVhMogAWjLAEJOkaKL0DL-ECD_eZngrCQqaUrQ6pubeA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix potential anon_vma locking issue in mprotect()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, aarcange@redhat.com

On Tue, Sep 4, 2012 at 4:46 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue,  4 Sep 2012 16:39:49 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> This change fixes an anon_vma locking issue in the following situation:
>> - vma has no anon_vma
>> - next has an anon_vma
>> - vma is being shrunk / next is being expanded, due to an mprotect call
>>
>> We need to take next's anon_vma lock to avoid races with rmap users
>> (such as page migration) while next is being expanded.
>
> hm, OK.  How serious was that bug?  I'm suspecting "only needed in
> 3.7".

That was my starting position as well. I'd expect the biggest issue
would be page migration races, and we do have assertions for that
case, and we've not been hitting them (that I know of). So, this
should not be a high frequency issue AFAICT.

I don't want to push for -stable backports myself, but I do think it's
nice to do a minimal patch so that it can easily be backported if we
decide to.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
