Date: Tue, 30 Aug 2005 12:18:30 +0100
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Message-ID: <20050830111830.GI26314@parcelfarce.linux.theplanet.co.uk>
References: <200508262246.j7QMkEoT013490@linux.jf.intel.com> <Pine.LNX.4.62.0508261559450.17433@schroedinger.engr.sgi.com> <200508270224.26423.ak@suse.de> <20050830001905.GA18279@linux.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050830001905.GA18279@linux.jf.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Lynch <rusty@linux.intel.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@engr.sgi.com>, Rusty Lynch <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 29, 2005 at 05:19:05PM -0700, Rusty Lynch wrote:
> So, assuming inlining the notifier_call_chain would address Christoph's
> conserns, is the following patch something like what you are sugesting?  
> This would make all the kdebug.h::notify_die() calls use the inline version. 

I think we need something more like this ...

include/linux/notifier.h:
+static inline int notifier_call_chain(struct notifier_block **n,
+					unsigned long val, void *v)
+{
+	if (n)
+		return __notifier_call_chain(n, val, v);
+	return NOTIFY_DONE;
+}
kernel/sys.c:
-int notifier_call_chain(struct notifier_block **n, unsigned long val, void *v)
+int __notifier_call_chain(struct notifier_block **n, unsigned long val, void *v)
-EXPORT_SYMBOL(notifier_call_chain);
+EXPORT_SYMBOL(__notifier_call_chain);

That way everyone gets both the quick test and the global size reduction.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
