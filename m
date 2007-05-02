Date: Wed, 2 May 2007 00:52:38 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
	(-1)
Message-ID: <20070502075238.GA9083@suse.de>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org> <46338AEB.2070109@imap.cc> <20070428141024.887342bd.akpm@linux-foundation.org> <4636248E.7030309@imap.cc> <20070430112130.b64321d3.akpm@linux-foundation.org> <46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org> <46383742.9050503@imap.cc> <20070502001000.8460fb31.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070502001000.8460fb31.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2007 at 12:10:00AM -0700, Andrew Morton wrote:
> On Wed, 02 May 2007 09:01:22 +0200 Tilman Schmidt <tilman@imap.cc> wrote:
> 
> > Am 30.04.2007 21:46 schrieb Andrew Morton:
> > > Not really - everything's tangled up.  A bisection search on the
> > > 2.6.21-rc7-mm2 driver tree would be the best bet.
> > 
> > And the winner is:
> > 
> > gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch
> > 
> > Reverting only that from 2.6.21-rc7-mm2 gives me a working kernel
> > again.
> 
> cripes.
> 
> +static ssize_t show_uevent(struct device *dev, struct device_attribute *attr,
> +                          char *buf)
> +{
> +       struct kobject *top_kobj;
> +       struct kset *kset;
> +       char *envp[32];
> +       char data[PAGE_SIZE];
> 
> That won't work too well with 4k stacks.

Tilman, here's a patch, can you try this on top of your tree that dies?

thanks,

greg k-h

---
 drivers/base/core.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -252,7 +252,7 @@ static ssize_t show_uevent(struct device
 	struct kobject *top_kobj;
 	struct kset *kset;
 	char *envp[32];
-	char data[PAGE_SIZE];
+	char *data = NULL;
 	char *pos;
 	int i;
 	size_t count = 0;
@@ -276,6 +276,10 @@ static ssize_t show_uevent(struct device
 		if (!kset->uevent_ops->filter(kset, &dev->kobj))
 			goto out;
 
+	data = (char *)get_zeroed_page(GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
 	/* let the kset specific function add its keys */
 	pos = data;
 	retval = kset->uevent_ops->uevent(kset, &dev->kobj,
@@ -290,6 +294,7 @@ static ssize_t show_uevent(struct device
 		count += sprintf(pos, "%s\n", envp[i]);
 	}
 out:
+	free_page((unsigned long)data);
 	return count;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
