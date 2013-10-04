Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id BA4866B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 21:28:07 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so3239691pbc.2
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 18:28:07 -0700 (PDT)
Message-ID: <1380850082.2280.18.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 1/2] mm,fs: introduce helpers around i_mmap_mutex
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 03 Oct 2013 18:28:02 -0700
In-Reply-To: <1380834035.2280.5.camel@buesod1.americas.hpqcorp.net>
References: <1380745066-9925-1-git-send-email-davidlohr@hp.com>
	 <1380745066-9925-2-git-send-email-davidlohr@hp.com>
	 <20131003135822.e0b2ca10fe5a460714bb82a3@linux-foundation.org>
	 <1380834035.2280.5.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2013-10-03 at 14:00 -0700, Davidlohr Bueso wrote:
> On Thu, 2013-10-03 at 13:58 -0700, Andrew Morton wrote:
> > On Wed,  2 Oct 2013 13:17:45 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 
> > > Various parts of the kernel acquire and release this mutex,
> > > so add i_mmap_lock_write() and immap_unlock_write() helper
> > > functions that will encapsulate this logic. The next patch
> > > will make use of these.
> > > 
> > > ...
> > >
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -478,6 +478,16 @@ struct block_device {
> > >  
> > >  int mapping_tagged(struct address_space *mapping, int tag);
> > >  
> > > +static inline void i_mmap_lock_write(struct address_space *mapping)
> > > +{
> > > +	mutex_lock(&mapping->i_mmap_mutex);
> > > +}
> > 
> > I don't understand the thinking behind the "_write".  There is no
> > "_read" and all callsites use "_write", so why not call it
> > i_mmap_lock()?
> > 
> > I *assume* the answer is "so we can later convert some sites to a new
> > i_mmap_lock_read()".  If so, the changelog should have discussed this. 
> > If not, still confused.
> > 
> 
> Yes, that's exactly right. I'll resend with an updated changelog.

So here's an updated changelog, I left it generic enough for us not to
rely on the lock type characteristics, since if/when changed, it can
remain a sleeping lock (rwsem) or not, for rwlock_t.

8<-----------------------------------------
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/2] mm,fs: introduce helpers around i_mmap_mutex

Various parts of the kernel acquire and release this mutex,
so add i_mmap_lock_write() and immap_unlock_write() helper
functions that will encapsulate this logic. The next patch
will make use of these.

Note that since this lock is currently a mutex, only introduce
write related functions. In the future, the lock type can be
changed and reading semantics can be added such that the lock 
can be shared when allowed.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/fs.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..b32e64f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -478,6 +478,16 @@ struct block_device {
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
+static inline void i_mmap_lock_write(struct address_space *mapping)
+{
+	mutex_lock(&mapping->i_mmap_mutex);
+}
+
+static inline void i_mmap_unlock_write(struct address_space *mapping)
+{
+	mutex_unlock(&mapping->i_mmap_mutex);
+}
+
 /*
  * Might pages of this file be mapped into userspace?
  */
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
