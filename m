Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A22DB6B0009
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 12:42:49 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id x4so10344708otx.23
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:42:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si7217885ott.161.2018.01.31.09.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 09:42:48 -0800 (PST)
Date: Wed, 31 Jan 2018 12:42:45 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180131174245.GE2912@redhat.com>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180131165646.GI29051@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Jan 31, 2018 at 04:56:46PM +0000, Al Viro wrote:
> On Mon, Jan 29, 2018 at 07:43:48PM -0500, Jerome Glisse wrote:
> > I started a patchset about $TOPIC a while ago, right now i am working on other
> > thing but i hope to have an RFC for $TOPIC before LSF/MM and thus would like a
> > slot during common track to talk about it as it impacts FS, BLOCK and MM (i am
> > assuming their will be common track).
> > 
> > Idea is that mapping (struct address_space) is available in virtualy all the
> > places where it is needed and that their should be no reasons to depend only on
> > struct page->mapping field. My patchset basicly add mapping to a bunch of vfs
> > callback (struct address_space_operations) where it is missing, changing call
> > site. Then i do an individual patch per filesystem to leverage the new argument
> > instead on struct page.
> 
> Oh?  What about the places like fs/coda?  Or block devices, for that matter...
> You can't count upon file->f_mapping->host == file_inode(file).

What matter is that the place that call an address_space_operations callback
already has mapping == page->mapping in many places this is obvious. For
instance page just have been looked up using mapping and thus you must have
mapping == page->mapping. But i believe this holds in all places. They are
few dark corners (fuse, splice, ...). Truncate also factor in all this as
page->mapping is use to determine if a page has been truncated, but it
should not be an issue.

So i am not counting on file->f_mapping->host == file_inode(file) but i might
count in _some_ place on vma->file->f_mapping == page->mapping of any non private
page inside that vma. AFAICT this holds for coda and should hold elsewhere too.

For block devices the idea is to use struct page and buffer_head (first one of
a page) as a key to find mapping (struct address_space) back.

The overall idea i have is that in any place in the kernel (except memory reclaim
but that's ok) we can either get mapping or buffer_head information without relying
on struct page and if we have either one and a struct page then we can find the
other one.

Like i said i am not done with a patchset for that yet so maybe i am too
optimistic. I have another patchset i need to finish first before i go back to
this. I hope to have an RFC sometime in February or March and maybe by then
i would have found a roadblock, i am crossing my fingers until then :)

If it turns out that it is not doable i will comment on this thread and we can
kill that of from the agenda.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
