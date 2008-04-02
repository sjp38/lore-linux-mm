From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] EMM: Fixup return value handling of emm_notify()
Date: Wed, 2 Apr 2008 12:03:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Christoph Lameter wrote:

> Here f.e. We can add a special emm_age() function that iterates 
> differently and does the | for you.

Well maybe not really necessary. How about this fix? Its likely a problem 
to stop callbacks if one callback returned an error.


Subject: EMM: Fixup return value handling of emm_notify()

Right now we stop calling additional subsystems if one callback returned
an error. That has the potential for causing additional trouble with the
subsystems that do not receive the callbacks they expect if one has failed.

So change the handling of error code to continue callbacks to other
subsystems but return the first error code encountered.

If a callback returns a positive return value then add up all the value
from all the calls. That can be used to establish how many references
exist (xpmem may want this feature at some point) or ensure that the
aging works the way Andrea wants it to (KVM, XPmem so far do not
care too much).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/rmap.c |   28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-04-02 11:46:20.738342852 -0700
+++ linux-2.6/mm/rmap.c	2008-04-02 12:03:57.672494320 -0700
@@ -299,27 +299,45 @@ void emm_notifier_register(struct emm_no
 }
 EXPORT_SYMBOL_GPL(emm_notifier_register);
 
-/* Perform a callback */
+/*
+ * Perform a callback
+ *
+ * The return of this function is either a negative error of the first
+ * callback that failed or a consolidated count of all the positive
+ * values that were returned by the callbacks.
+ */
 int __emm_notify(struct mm_struct *mm, enum emm_operation op,
 		unsigned long start, unsigned long end)
 {
 	struct emm_notifier *e = rcu_dereference(mm->emm_notifier);
 	int x;
+	int result = 0;
 
 	while (e) {
-
 		if (e->callback) {
 			x = e->callback(e, mm, op, start, end);
-			if (x)
-				return x;
+
+			/*
+			 * Callback may return a positive value to indicate a count
+			 * or a negative error code. We keep the first error code
+			 * but continue to perform callbacks to other subscribed
+			 * subsystems.
+			 */
+			if (x && result >= 0) {
+				if (x >= 0)
+					result += x;
+				else
+					result = x;
+			}
 		}
+
 		/*
 		 * emm_notifier contents (e) must be fetched after
 		 * the retrival of the pointer to the notifier.
 		 */
 		e = rcu_dereference(e->next);
 	}
-	return 0;
+	return result;
 }
 EXPORT_SYMBOL_GPL(__emm_notify);
 #endif
